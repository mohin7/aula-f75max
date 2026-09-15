import AulaDesignSystem
import AulaKit
import SwiftUI

struct DashboardView: View {
    @Environment(KeyboardStore.self) private var store
    @AppStorage(PreferenceKey.timeFormat) private var timeFormat = TimeFormatPreference.system.rawValue
    @Environment(AppRouter.self) private var router
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    var body: some View {
        @Bindable var router = router

        ScrollView {
            VStack(alignment: .leading, spacing: Spacing.xl) {
                header

                ForEach(visibleNotices) { notice in
                    Callout(
                        notice.tone,
                        title: notice.title,
                        message: notice.message,
                        actionTitle: notice.actionTitle,
                        action: notice.action,
                        onDismiss: {
                            withAnimation(Motion.animation(Motion.smooth, reduceMotion: reduceMotion)) {
                                _ = router.dismissedNotices.insert(notice.id)
                            }
                        }
                    )
                    .transition(.opacity.combined(with: .move(edge: .top)))
                }

                KeyboardStageCard(selection: $router.selectedKeyIDs)
                    .overlay(alignment: .topTrailing) {
                        if let key = selectedKey {
                            KeyInspector(key: key) { router.selectedKeyIDs = [] }
                                .padding(Spacing.md)
                                .transition(.move(edge: .trailing).combined(with: .opacity))
                        }
                    }
                    .animation(Motion.animation(Motion.smooth, reduceMotion: reduceMotion), value: selectedKey?.id)

                statGrid

                if router.showsKeyTester {
                    KeyTesterCard()
                        .transition(.opacity)
                }
            }
            .padding(Spacing.xl)
            .pageContainer(.wide)
        }
        .background(Palette.canvas)
    }

    private var selectedKey: KeyDefinition? {
        guard router.selectedKeyIDs.count == 1, let id = router.selectedKeyIDs.first else { return nil }
        return store.keyByID[id]
    }

    // MARK: Header

    private var header: some View {
        HStack(alignment: .center, spacing: Spacing.md) {
            VStack(alignment: .leading, spacing: Spacing.xxs) {
                Text(store.primary?.productName ?? store.layout.name)
                    .font(Typography.largeTitle)
                    .foregroundStyle(Palette.textPrimary)
                HStack(spacing: Spacing.xs) {
                    StatusPill(connectionLabel, state: store.isConnected ? .connected : .disconnected)
                    if store.isDemo {
                        StatusPill("Demo", state: .warning)
                    }
                    Toggle(isOn: Binding(get: { router.showsKeyTester }, set: { router.showsKeyTester = $0 })) {
                        Label("Key Tester", systemImage: "keyboard.badge.eye")
                    }
                    .toggleStyle(.button)
                    .controlSize(.small)
                    .help("Show live key events and check the layout against your keyboard")
                }
            }
            Spacer()
            BatteryPanel()
        }
    }

    private var connectionLabel: String {
        guard let primary = store.primary else { return "Not connected" }
        return "Connected · \(primary.kind.title)"
    }

    private struct Notice: Identifiable {
        /// Includes the condition that triggered it, so a changed situation shows again.
        let id: String
        let tone: Callout.Tone
        let title: String
        let message: String
        var actionTitle: String?
        var action: (() -> Void)?
    }

    private var visibleNotices: [Notice] {
        [lowBatteryNotice, capabilityNotice, inputMonitoringNotice]
            .compactMap { $0 }
            .filter { !router.dismissedNotices.contains($0.id) }
    }

    private var lowBatteryNotice: Notice? {
        guard store.isBatteryLevelLive, !store.isPluggedIn, let level = store.batteryLevel, level <= 20 else { return nil }
        let critical = level <= 10
        return Notice(
            id: critical ? "battery.critical" : "battery.low",
            tone: critical ? .danger : .warning,
            title: "Battery at \(level)%",
            message: "Plug in the USB-C cable to charge. Turning lighting off or lowering brightness makes the battery last much longer."
        )
    }

    private var capabilityNotice: Notice? {
        guard let primary = store.primary else {
            return Notice(
                id: "connection.none",
                tone: .info,
                title: "Connect your F75 Max",
                message: "Plug in USB-C, insert the 2.4G receiver, or pair over Bluetooth. AULA Studio picks it up automatically, no restart needed."
            )
        }
        if primary.kind == .bluetooth {
            return Notice(
                id: "connection.bluetooth",
                tone: .info,
                title: "Connected over Bluetooth",
                message: "Live keys, knob and battery work over Bluetooth. To change lighting, the screen or keyboard settings, plug in the USB-C cable; the keyboard doesn't accept changes over Bluetooth. It keeps them when you switch back."
            )
        }
        return nil
    }

    private var inputMonitoringNotice: Notice? {
        guard store.inputAccess != .granted else { return nil }
        let denied = store.inputAccess == .denied
        return Notice(
            id: "inputMonitoring",
            tone: .info,
            title: "Enable live key preview",
            message: "Allow Input Monitoring so the on-screen keyboard can mirror your key presses and knob turns. AULA Studio never records or stores what you type."
                + (denied ? " Turn on AULA Studio (or your terminal, if you launched from one), then come back." : ""),
            actionTitle: denied ? "Open Settings" : "Allow",
            action: { [store] in store.requestInputMonitoring() }
        )
    }

    // MARK: Stats

    private var statGrid: some View {
        let lighting = store.lighting
        let primary = store.primary
        let unknown = "—"

        return LazyVGrid(columns: [GridItem(.adaptive(minimum: 200), spacing: Spacing.md)], spacing: Spacing.md) {
            StatCard(
                "Keyboard",
                value: primary?.productName ?? "Not connected",
                detail: primary.map { "\($0.endpoints.count) HID interface\($0.endpoints.count == 1 ? "" : "s")" },
                symbol: "keyboard"
            )
            StatCard(
                "Connection",
                value: primary?.kind.title ?? "None",
                detail: primary.map { $0.hasConfigurationChannel ? "Configuration available" : ($0.kind == .bluetooth ? "Keys, knob and battery" : "Keystrokes only") },
                symbol: primary?.kind.symbolName ?? "cable.connector.slash",
                tint: primary == nil ? Palette.danger : Palette.success
            )
            StatCard(
                "Keyboard Clock",
                value: store.control.lastClockSync.map { TimeFormatPreference(rawValue: timeFormat)?.string(from: $0) ?? "" } ?? "Not synced",
                detail: store.control.lastClockSync.map { Calendar.current.isDateInToday($0) ? "Synced today" : "Synced \($0.formatted(date: .abbreviated, time: .omitted))" } ?? "Syncs when you plug in USB-C",
                symbol: "clock"
            )
            StatCard(
                "Lighting",
                value: lighting.mode.title,
                detail: lighting.multicolor ? "Multicolor" : lighting.color.hexString,
                symbol: lighting.mode.symbolName,
                tint: Color(rgb: lighting.color)
            )
            StatCard("Brightness", value: "\(lighting.brightness * 20)%", detail: "Level \(lighting.brightness) of 5", symbol: "sun.max")
            StatCard(
                "Polling Rate",
                value: primary?.kind.ratedPollingRate ?? unknown,
                detail: primary?.kind == .bluetooth ? "Set by the Bluetooth link" : "Manufacturer rating",
                symbol: "waveform.path"
            )
            StatCard(
                "Firmware",
                value: firmwareValue ?? unknown,
                detail: firmwareDetail,
                symbol: "cpu"
            )
            StatCard(
                "Sleep Timer",
                value: store.control.settings.sleepTime.title,
                detail: "Change in Settings → Keyboard",
                symbol: "moon.zzz"
            )
            StatCard(
                "Key Response",
                value: "Level \(store.control.settings.responseLevel)",
                detail: KeyboardSettings.latencyDescription(level: store.control.settings.responseLevel).components(separatedBy: " · ").first,
                symbol: "timer"
            )
        }
    }

    /// Bluetooth reports "2024.07.26 SVN0138": show the build as the value and the date as the detail.
    private var firmwareValue: String? {
        if let revision = store.bluetoothInfo?.softwareRevision {
            return revision.split(separator: " ").last.map(String.init) ?? revision
        }
        return store.primary?.hidVersion.map { "v\($0)" }
    }

    private var firmwareDetail: String {
        if let revision = store.bluetoothInfo?.softwareRevision, let date = revision.split(separator: " ").first, revision.contains(" ") {
            return "Built \(date)"
        }
        return "Reported HID device version"
    }

}

/// The large surface that hosts the keyboard.
struct KeyboardStageCard: View {
    @Binding var selection: Set<String>

    var body: some View {
        KeyboardStage(selection: $selection)
            .padding(Spacing.xxl)
            .frame(maxWidth: .infinity)
            .background {
                RoundedRectangle(cornerRadius: Radius.xxl, style: .continuous)
                    .fill(
                        RadialGradient(
                            colors: [Palette.surfaceRaised, Palette.surfaceSunken],
                            center: .top,
                            startRadius: 0,
                            endRadius: 900
                        )
                    )
            }
            .overlay {
                RoundedRectangle(cornerRadius: Radius.xxl, style: .continuous).strokeBorder(Palette.stroke, lineWidth: 1)
            }
    }
}
