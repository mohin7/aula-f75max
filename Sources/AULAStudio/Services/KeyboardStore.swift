import AppKit
import AulaDesignSystem
import AulaKit
import SwiftUI
import Foundation
import Observation

/// Single source of truth for keyboard state in the UI. Views read it and
/// feature view models change it. Hardware access goes through injected
/// protocols, so demo and test sources can take the place of IOKit.
@MainActor
@Observable
final class KeyboardStore {
    struct PressRecord: Hashable {
        let keyID: String
        let time: TimeInterval
    }

    struct EventRecord: Identifiable, Hashable {
        let id = UUID()
        let usage: HIDUsage
        let keyID: String?
        let time: Date
    }

    let layout: KeyboardLayout
    let keyByID: [String: KeyDefinition]

    // MARK: Connection

    private(set) var keyboards: [ConnectedKeyboard] = []
    private(set) var endpoints: [HIDEndpoint] = []
    private(set) var isDemo = false

    /// The most capable link wins: wired > 2.4G > Bluetooth.
    var primary: ConnectedKeyboard? { keyboards.first }
    var isConnected: Bool { primary != nil }
    var capabilities: DeviceCapabilities { primary?.capabilities ?? [] }

    // MARK: Live input

    private(set) var inputAccess: InputMonitoringAccess = .current
    private(set) var pressedKeyIDs: Set<String> = []
    /// Last press time for each key (reference-date seconds), used by reactive lighting.
    private(set) var lastPressTime: [String: TimeInterval] = [:]
    private(set) var recentPresses: [PressRecord] = []
    private(set) var knobAngle: Double = 0
    private(set) var isKnobPressed = false
    private(set) var capsLockOn = false

    // MARK: Key tester

    private(set) var recentEvents: [EventRecord] = []
    private(set) var testedKeyIDs: Set<String> = []

    // MARK: Battery

    struct BatteryReading: Codable, Equatable {
        let level: Int
        let date: Date
    }

    /// Live level. The keyboard reports it over Bluetooth (GATT Battery Service); AULA's own driver
    /// only reads it over 2.4G. It's `nil` on USB-C.
    private(set) var batteryLevel: Int?
    /// Most recent real reading, kept across restarts and connection changes.
    private(set) var lastBatteryReading: BatteryReading? {
        didSet {
            guard !isDemo, let lastBatteryReading, let data = try? JSONEncoder().encode(lastBatteryReading) else { return }
            UserDefaults.standard.set(data, forKey: DefaultsKey.lastBattery)
        }
    }
    /// Standard GATT info when connected over Bluetooth (battery, firmware revision).
    private(set) var bluetoothInfo: BluetoothKeyboardInfo?

    /// USB-C powers the keyboard and charges its battery.
    var isPluggedIn: Bool { primary?.kind == .wired }
    var isCharging: Bool { isPluggedIn }

    /// What to show: the live level, or the last known reading when there's no live one.
    var displayedBatteryLevel: Int? { batteryLevel ?? lastBatteryReading?.level }
    var isBatteryLevelLive: Bool { batteryLevel != nil }

    var lighting: LightingSettings {
        didSet {
            persistLighting()
            if lighting != oldValue { control.applyLighting(lighting) }
        }
    }

    /// Writes lighting, settings, clock and screen to the keyboard over USB-C.
    let control = KeyboardControl()

    var legendMode: OSLegendMode {
        didSet { UserDefaults.standard.set(legendMode.rawValue, forKey: DefaultsKey.legendMode) }
    }

    // MARK: Dependencies

    private var discovery: DeviceDiscovering
    private var keySource: KeyEventSource
    private let bluetooth: BluetoothKeyboardInfoSource?
    private let liveSourcesFactory: @MainActor () -> (DeviceDiscovering, KeyEventSource)
    private let demoSourcesFactory: @MainActor () -> (DeviceDiscovering, KeyEventSource)
    private var activationObserver: NSObjectProtocol?
    private var pressExpiryTask: Task<Void, Never>?
    private static let pressLifetime: TimeInterval = 1.5

    init(
        layout: KeyboardLayout = .f75Max,
        demo: Bool,
        bluetooth: BluetoothKeyboardInfoSource? = BluetoothKeyboardMonitor(),
        live: @escaping @MainActor () -> (DeviceDiscovering, KeyEventSource) = { (HIDDeviceMonitor(), KeyEventMonitor()) },
        demoSources: @escaping @MainActor () -> (DeviceDiscovering, KeyEventSource) = { (DemoDeviceDiscovery(), DemoKeyEventSource()) }
    ) {
        self.layout = layout
        self.keyByID = Dictionary(uniqueKeysWithValues: layout.keys.map { ($0.id, $0) })
        self.liveSourcesFactory = live
        self.demoSourcesFactory = demoSources
        self.bluetooth = bluetooth
        (discovery, keySource) = demo ? demoSources() : live()
        isDemo = demo
        lighting = Self.loadLighting()
        legendMode = UserDefaults.standard.string(forKey: DefaultsKey.legendMode).flatMap(OSLegendMode.init) ?? .mac
        if !demo {
            lastBatteryReading = UserDefaults.standard.data(forKey: DefaultsKey.lastBattery)
                .flatMap { try? JSONDecoder().decode(BatteryReading.self, from: $0) }
        }
    }

    func start() {
        bind()
        discovery.start()
        inputAccess = keySource.start()
        refreshCapsLock()
        activationObserver = NotificationCenter.default.addObserver(
            forName: NSApplication.didBecomeActiveNotification, object: nil, queue: .main
        ) { [weak self] _ in
            MainActor.assumeIsolated { self?.handleAppActivation() }
        }
    }

    func setDemoMode(_ enabled: Bool) {
        guard enabled != isDemo else { return }
        discovery.stop()
        keySource.stop()
        (discovery, keySource) = enabled ? demoSourcesFactory() : liveSourcesFactory()
        isDemo = enabled
        keyboards = []
        endpoints = []
        batteryLevel = nil
        bluetoothInfo = nil
        if enabled { bluetooth?.stop() }
        control.connectionChanged(to: nil, isDemo: enabled)
        bind()
        discovery.start()
        inputAccess = keySource.start()
    }

    /// Asks for Input Monitoring. Requesting also adds the app to the list in
    /// System Settings, so if macOS won't show a prompt (already denied), open that pane.
    func requestInputMonitoring() {
        inputAccess = InputMonitoringAccess.request()
        if inputAccess == .granted {
            inputAccess = keySource.start()
        } else {
            NSWorkspace.shared.open(InputMonitoringAccess.settingsURL)
        }
    }

    func resetKeyTester() {
        testedKeyIDs.removeAll()
        recentEvents.removeAll()
    }

    func pressAge(for keyID: String, at time: TimeInterval) -> Double? {
        lastPressTime[keyID].map { time - $0 }
    }

    /// Follows the keyboard color when it's vivid enough to use as UI chrome.
    var studioAccent: Color {
        guard lighting.mode != .off, !lighting.multicolor else { return Color(hex: 0x6E7BFF) }
        let hsv = lighting.color.hsv
        guard hsv.saturation > 0.25, hsv.value > 0.35 else { return Color(hex: 0x6E7BFF) }
        return Color(rgb: LEDColor(hsv: HSV(hue: hsv.hue, saturation: min(hsv.saturation, 0.85), value: min(hsv.value, 0.9))))
    }

    // MARK: - Private

    private func bind() {
        discovery.onChange = { [weak self] endpoints in
            self?.apply(endpoints: endpoints)
        }
        keySource.onEvent = { [weak self] event in
            self?.handle(event)
        }
        bluetooth?.onUpdate = { [weak self] info in
            self?.apply(bluetoothInfo: info)
        }
    }

    private func handleAppActivation() {
        refreshCapsLock()
        // The user may have just granted permission in System Settings.
        if inputAccess != .granted {
            inputAccess = keySource.start()
        }
    }

    private func apply(endpoints: [HIDEndpoint]) {
        self.endpoints = endpoints
        let previousKind = primary?.kind
        keyboards = ConnectedKeyboard.group(endpoints)
        if primary?.kind != previousKind || keyboards.isEmpty {
            control.connectionChanged(to: primary?.kind, isDemo: isDemo)
        }

        if isDemo {
            batteryLevel = primary == nil ? nil : 82
        } else if keyboards.contains(where: { $0.kind == .bluetooth }) {
            bluetooth?.refresh()
        } else {
            bluetooth?.stop()
        }
        if primary == nil { batteryLevel = nil }
    }

    private func apply(bluetoothInfo info: BluetoothKeyboardInfo?) {
        guard !isDemo else { return }
        bluetoothInfo = info
        batteryLevel = info?.batteryLevel
        if let level = info?.batteryLevel {
            lastBatteryReading = BatteryReading(level: level, date: Date())
        }
    }

    private func handle(_ event: KeyEvent) {
        let now = Date.timeIntervalSinceReferenceDate

        if let knob = layout.knob, event.usage.page == HIDUsage.Page.consumer {
            switch event.usage {
            case knob.rotateClockwise where event.isDown: knobAngle += 15
            case knob.rotateCounterClockwise where event.isDown: knobAngle -= 15
            case knob.press: isKnobPressed = event.isDown
            default: break
            }
            if event.isDown { record(event.usage, keyID: nil, time: now) }
            return
        }

        let keys = layout.keys(for: event.usage, mode: legendMode)
        for key in keys {
            if event.isDown {
                pressedKeyIDs.insert(key.id)
                lastPressTime[key.id] = now
                testedKeyIDs.insert(key.id)
                recentPresses.append(PressRecord(keyID: key.id, time: now))
            } else {
                pressedKeyIDs.remove(key.id)
            }
        }
        if event.isDown {
            recentPresses.removeAll { now - $0.time > Self.pressLifetime }
            if recentPresses.count > 24 { recentPresses.removeFirst(recentPresses.count - 24) }
            record(event.usage, keyID: keys.first?.id, time: now)
            schedulePressExpiry()
        }
        if event.usage == .keyboard(0x39), !event.isDown {
            refreshCapsLock()
        }
    }

    /// Once the last press effect has faded, clear presses so the preview timeline can pause.
    private func schedulePressExpiry() {
        pressExpiryTask?.cancel()
        pressExpiryTask = Task { [weak self] in
            try? await Task.sleep(for: .seconds(Self.pressLifetime))
            guard !Task.isCancelled else { return }
            self?.recentPresses.removeAll()
        }
    }

    private func record(_ usage: HIDUsage, keyID: String?, time: TimeInterval) {
        recentEvents.insert(EventRecord(usage: usage, keyID: keyID, time: Date(timeIntervalSinceReferenceDate: time)), at: 0)
        if recentEvents.count > 12 { recentEvents.removeLast(recentEvents.count - 12) }
    }

    private func refreshCapsLock() {
        capsLockOn = CGEventSource.flagsState(.combinedSessionState).contains(.maskAlphaShift)
    }

    private enum DefaultsKey {
        static let lighting = "lighting.v1"
        static let legendMode = "legendMode"
        static let lastBattery = "battery.lastReading.v1"
    }

    private func persistLighting() {
        if let data = try? JSONEncoder().encode(lighting) {
            UserDefaults.standard.set(data, forKey: DefaultsKey.lighting)
        }
    }

    private static func loadLighting() -> LightingSettings {
        guard let data = UserDefaults.standard.data(forKey: DefaultsKey.lighting),
              let settings = try? JSONDecoder().decode(LightingSettings.self, from: data) else {
            return LightingSettings()
        }
        return settings
    }
}
