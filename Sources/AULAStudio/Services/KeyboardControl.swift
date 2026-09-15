import AppKit
import AulaKit
import Foundation
import Observation

/// Everything the app writes to the keyboard over USB-C: lighting, settings, clock and screen.
///
/// One `WiredKeyboardDriver` (an actor) carries every command, so a clock sync can never
/// interleave with a lighting write. Lighting and settings edits coalesce, keeping only the
/// newest values while a write is in flight.
@MainActor
@Observable
final class KeyboardControl {
    enum WriteStatus: Equatable {
        case idle
        case writing
        case done
        case failed(String)
    }

    struct UploadState: Equatable {
        var sent: Int
        var total: Int
        var startedAt: Date

        var fraction: Double { total == 0 ? 0 : Double(sent) / Double(total) }

        var remaining: TimeInterval? {
            guard sent > 2 else { return nil }
            let elapsed = Date().timeIntervalSince(startedAt)
            return elapsed / Double(sent) * Double(total - sent)
        }
    }

    /// Why writing isn't possible right now, or `nil` when USB-C is ready.
    private(set) var unavailableReason: String? = "Keyboard not connected."
    var isAvailable: Bool { unavailableReason == nil }

    private(set) var lightingStatus: WriteStatus = .idle
    private(set) var settingsStatus: WriteStatus = .idle
    private(set) var clockStatus: WriteStatus = .idle
    private(set) var lastClockSync: Date?
    private(set) var upload: UploadState?
    private(set) var uploadStatus: WriteStatus = .idle

    /// Last settings sent (the firmware can't report them back).
    var settings: KeyboardSettings {
        didSet {
            guard settings != oldValue else { return }
            persist(settings, key: Keys.settings)
            queueSettings()
        }
    }

    /// Shows the keyboard clock as 1–12 instead of 0–23 (the firmware has no AM/PM).
    var keyboardTwelveHour: Bool {
        didSet {
            guard keyboardTwelveHour != oldValue else { return }
            UserDefaults.standard.set(keyboardTwelveHour, forKey: Keys.keyboardTwelveHour)
            Task { await syncClock() }
        }
    }

    var autoSyncClock: Bool {
        didSet {
            UserDefaults.standard.set(autoSyncClock, forKey: Keys.autoSyncClock)
            updateClockTimer()
            if autoSyncClock, !oldValue { Task { await syncClock() } }
        }
    }

    private let driver = WiredKeyboardDriver()
    private var pendingLighting: LightingSettings?
    private var lightingWorker: Task<Void, Never>?
    private var settingsWorker: Task<Void, Never>?
    private var settingsDirty = false
    private var clockTimer: Task<Void, Never>?
    private var clockObservers: [NSObjectProtocol] = []

    /// Roughly how long the begin and select handshakes take before the time packet goes out.
    private static let clockSendLatency: TimeInterval = 0.2

    private enum Keys {
        static let settings = "keyboard.settings.v1"
        static let autoSyncClock = "keyboard.autoSyncClock"
        static let lastClockSync = "keyboard.lastClockSync"
        static let keyboardTwelveHour = "keyboard.twelveHourClock"
    }

    init() {
        settings = UserDefaults.standard.data(forKey: Keys.settings)
            .flatMap { try? JSONDecoder().decode(KeyboardSettings.self, from: $0) } ?? KeyboardSettings()
        autoSyncClock = UserDefaults.standard.object(forKey: Keys.autoSyncClock) as? Bool ?? true
        keyboardTwelveHour = UserDefaults.standard.bool(forKey: Keys.keyboardTwelveHour)
        lastClockSync = UserDefaults.standard.object(forKey: Keys.lastClockSync) as? Date
        observeClockChanges()
    }

    /// Re-syncs after sleep and when the Mac's clock or time zone changes.
    private func observeClockChanges() {
        let resync: @Sendable (Notification) -> Void = { [weak self] _ in
            Task { @MainActor in
                guard let self, self.autoSyncClock, self.isAvailable else { return }
                // Give USB a moment to come back after wake.
                try? await Task.sleep(for: .seconds(2))
                await self.syncClock()
            }
        }
        let workspace = NSWorkspace.shared.notificationCenter
        clockObservers = [
            workspace.addObserver(forName: NSWorkspace.didWakeNotification, object: nil, queue: .main, using: resync),
            NotificationCenter.default.addObserver(forName: .NSSystemClockDidChange, object: nil, queue: .main, using: resync),
            NotificationCenter.default.addObserver(forName: .NSSystemTimeZoneDidChange, object: nil, queue: .main, using: resync),
        ]
    }

    /// Time until just after the next full hour, so the sync lands on the new hour.
    static func secondsUntilNextHour(from now: Date = Date(), calendar: Calendar = .current) -> TimeInterval {
        let nextHour = calendar.nextDate(after: now, matching: DateComponents(minute: 0, second: 0), matchingPolicy: .nextTime) ?? now.addingTimeInterval(3600)
        return max(1, nextHour.timeIntervalSince(now) + 0.5)
    }

    private func updateClockTimer() {
        clockTimer?.cancel()
        clockTimer = nil
        guard isAvailable, autoSyncClock else { return }
        // Re-sync on every hour: this corrects drift, and in 12-hour mode it turns the
        // firmware's 13:00 into 1:00 right away.
        clockTimer = Task { [weak self] in
            while !Task.isCancelled {
                try? await Task.sleep(for: .seconds(Self.secondsUntilNextHour()))
                guard !Task.isCancelled, let self else { return }
                await self.syncClock()
            }
        }
    }

    // MARK: Connection

    func connectionChanged(to kind: ConnectionKind?, isDemo: Bool) {
        let wasAvailable = isAvailable
        switch kind {
        case _ where isDemo:
            unavailableReason = "Demo keyboard: changes stay on screen."
        case .wired:
            unavailableReason = nil
        case .bluetooth:
            unavailableReason = "The F75 Max doesn't accept settings over Bluetooth (AULA's own driver says the same). Plug in the USB-C cable. The keyboard keeps everything when you switch back."
        case .dongle:
            unavailableReason = "Settings over the 2.4G receiver are coming soon. Use the USB-C cable for now."
        case nil:
            unavailableReason = "Keyboard not connected."
        }
        if isAvailable, !wasAvailable, autoSyncClock {
            Task { await syncClock() }
        }
        if isAvailable != wasAvailable { updateClockTimer() }
        if !isAvailable {
            lightingStatus = .idle
            settingsStatus = .idle
            clockStatus = .idle
        }
    }

    // MARK: Lighting

    /// Queues `lighting` for the keyboard. Only the newest request is sent.
    func applyLighting(_ lighting: LightingSettings) {
        guard isAvailable else { return }
        pendingLighting = lighting
        guard lightingWorker == nil else { return }
        lightingWorker = Task { [weak self] in
            // Let a burst of edits (a slider drag) settle into one write.
            try? await Task.sleep(for: .milliseconds(60))
            await self?.drainLighting()
        }
    }

    private func drainLighting() async {
        while let next = pendingLighting, isAvailable {
            pendingLighting = nil
            lightingStatus = .writing
            do {
                try await driver.applyLighting(next)
                lightingStatus = .done
            } catch {
                lightingStatus = .failed(error.localizedDescription)
            }
        }
        lightingWorker = nil
    }

    // MARK: Settings

    func resendSettings() {
        queueSettings()
    }

    private func queueSettings() {
        guard isAvailable else { return }
        settingsDirty = true
        guard settingsWorker == nil else { return }
        settingsWorker = Task { [weak self] in
            try? await Task.sleep(for: .milliseconds(150))
            await self?.drainSettings()
        }
    }

    private func drainSettings() async {
        while settingsDirty, isAvailable {
            settingsDirty = false
            settingsStatus = .writing
            do {
                try await driver.applySettings(settings)
                settingsStatus = .done
            } catch {
                settingsStatus = .failed(error.localizedDescription)
            }
        }
        settingsWorker = nil
    }

    // MARK: Clock

    func syncClock() async {
        guard isAvailable else { return }
        clockStatus = .writing
        do {
            let now = Date()
            // The firmware takes whole seconds. Aim for the moment the time packet arrives, rounded.
            let target = Date(timeIntervalSinceReferenceDate: (now.timeIntervalSinceReferenceDate + Self.clockSendLatency).rounded())
            try await driver.syncClock(date: target, twelveHour: keyboardTwelveHour)
            lastClockSync = now
            UserDefaults.standard.set(now, forKey: Keys.lastClockSync)
            clockStatus = .done
        } catch {
            clockStatus = .failed(error.localizedDescription)
        }
    }

    // MARK: Screen

    var isUploading: Bool { upload != nil }

    func clearUploadStatus() {
        if !isUploading { uploadStatus = .idle }
    }

    /// Uploads fitted frames to the screen. Returns whether the keyboard confirmed every chunk.
    @discardableResult
    func uploadScreen(_ frames: [DisplayEncoder.Frame]) async -> Bool {
        guard isAvailable, !isUploading else { return false }
        upload = UploadState(sent: 0, total: 0, startedAt: Date())
        let stream = await Task.detached(priority: .userInitiated) { DisplayEncoder.stream(for: frames) }.value
        let total = stream.count / DisplayEncoder.chunkLength
        upload = UploadState(sent: 0, total: total, startedAt: Date())
        uploadStatus = .writing
        defer { upload = nil }
        do {
            let acknowledged = try await driver.uploadDisplay(stream) { progress in
                Task { @MainActor [weak self] in
                    self?.upload?.sent = progress.sentChunks
                }
            }
            if acknowledged == total {
                uploadStatus = .done
                return true
            }
            uploadStatus = .failed("The keyboard confirmed \(acknowledged) of \(total) parts. Try uploading again.")
            return false
        } catch {
            uploadStatus = .failed(error.localizedDescription)
            return false
        }
    }

    private func persist<T: Encodable>(_ value: T, key: String) {
        if let data = try? JSONEncoder().encode(value) {
            UserDefaults.standard.set(data, forKey: key)
        }
    }
}
