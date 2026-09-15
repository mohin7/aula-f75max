import AulaDesignSystem
import AulaKit
import SwiftUI

struct SettingsView: View {
    @Environment(KeyboardStore.self) private var store

    @AppStorage(PreferenceKey.appearance) private var appearance = AppearancePreference.system.rawValue
    @AppStorage(PreferenceKey.accentFollowsLighting) private var accentFollowsLighting = true
    @AppStorage(PreferenceKey.showMenuBarIcon) private var showMenuBarIcon = true
    @AppStorage(PreferenceKey.demoMode) private var demoMode = false

    var body: some View {
        @Bindable var store = store

        ScrollView {
            VStack(alignment: .leading, spacing: Spacing.xl) {
                Text("Settings").font(Typography.largeTitle).foregroundStyle(Palette.textPrimary)

                KeyboardSettingsGroup()

                TimeSettingsGroup()

                group("Appearance") {
                    VStack(alignment: .leading, spacing: Spacing.xs) {
                        Text("Theme").font(Typography.label).foregroundStyle(Palette.textSecondary)
                        StudioSegmentedControl(
                            AppearancePreference.allCases,
                            selection: Binding(
                                get: { AppearancePreference(rawValue: appearance) ?? .system },
                                set: { appearance = $0.rawValue }
                            )
                        ) { Text($0.title) }
                        .frame(maxWidth: 320)
                    }
                    ToggleRow("Accent follows keyboard lighting", detail: "Tints the app with your current RGB color", isOn: $accentFollowsLighting)
                }

                group("Keyboard") {
                    VStack(alignment: .leading, spacing: Spacing.xs) {
                        Text("Legends").font(Typography.label).foregroundStyle(Palette.textSecondary)
                        StudioSegmentedControl(OSLegendMode.allCases, selection: $store.legendMode) { Text($0.title) }
                            .frame(maxWidth: 200)
                        Text("Match the keyboard's Win/Mac switch so modifiers show and map correctly.")
                            .font(Typography.caption)
                            .foregroundStyle(Palette.textTertiary)
                    }
                }

                group("General") {
                    ToggleRow("Show menu bar icon", detail: "Quick lighting controls and status", isOn: $showMenuBarIcon)
                    HStack {
                        VStack(alignment: .leading, spacing: Spacing.xxxs) {
                            Text("Input Monitoring").font(Typography.body).foregroundStyle(Palette.textPrimary)
                            Text(inputAccessDescription).font(Typography.caption).foregroundStyle(Palette.textSecondary)
                        }
                        Spacer()
                        if store.inputAccess != .granted {
                            Button(store.inputAccess == .denied ? "Open Settings" : "Allow") {
                                store.requestInputMonitoring()
                            }
                            .buttonStyle(.studioSecondary)
                            .controlSize(.small)
                        } else {
                            StatusPill("Allowed", state: .connected)
                        }
                    }
                }

                group("Developer") {
                    ToggleRow("Demo keyboard", detail: "Simulates a wired F75 Max with typing, for working without hardware", isOn: $demoMode)
                        .onChange(of: demoMode) { _, enabled in store.setDemoMode(enabled) }
                    DiagnosticsView()
                }
            }
            .padding(Spacing.xl)
            .pageContainer(.readable)
        }
        .background(Palette.canvas)
    }

    private var inputAccessDescription: String {
        switch store.inputAccess {
        case .granted: "Live key preview and Key Tester are on."
        case .denied: "Turned off in System Settings → Privacy & Security."
        case .notDetermined: "Needed to mirror key presses on screen."
        }
    }

    private func group<Content: View>(_ title: String, @ViewBuilder content: () -> Content) -> some View {
        SettingsGroup(title, content: content)
    }
}

struct SettingsGroup<Content: View, Accessory: View>: View {
    private let title: String
    private let content: Content
    private let accessory: Accessory

    init(_ title: String, @ViewBuilder content: () -> Content, @ViewBuilder accessory: () -> Accessory) {
        self.title = title
        self.content = content()
        self.accessory = accessory()
    }

    var body: some View {
        VStack(alignment: .leading, spacing: Spacing.sm) {
            HStack {
                Text(title).font(Typography.eyebrow).textCase(.uppercase).foregroundStyle(Palette.textTertiary)
                Spacer()
                accessory
            }
            StudioCard(padding: Spacing.lg) {
                VStack(alignment: .leading, spacing: Spacing.lg) {
                    content
                }
            }
        }
    }
}

extension SettingsGroup where Accessory == EmptyView {
    init(_ title: String, @ViewBuilder content: () -> Content) {
        self.init(title, content: content) { EmptyView() }
    }
}

/// Key response time, sleep time and key locks. Written to the keyboard as you change them.
struct KeyboardSettingsGroup: View {
    @Environment(KeyboardStore.self) private var store

    var body: some View {
        @Bindable var control = store.control

        SettingsGroup("Keyboard") {
            if let reason = control.unavailableReason {
                Callout(.info, title: "Connect USB-C to change these", message: reason)
            } else if case .failed(let message) = control.settingsStatus {
                Callout(.danger, title: "Couldn't update the keyboard", message: message, actionTitle: "Retry") {
                    control.resendSettings()
                }
            }

            Group {
                VStack(alignment: .leading, spacing: Spacing.xs) {
                    Text("Key response time").font(Typography.body).foregroundStyle(Palette.textPrimary)
                    StudioSegmentedControl(Array(KeyboardSettings.responseLevels), selection: $control.settings.responseLevel) { level in
                        Text(level == 1 ? "1 · Fastest" : level == 5 ? "5 · Stable" : "\(level)")
                    }
                    Text(KeyboardSettings.latencyDescription(level: control.settings.responseLevel) + ". Raise it if keys double-type.")
                        .font(Typography.caption)
                        .foregroundStyle(Palette.textTertiary)
                }

                VStack(alignment: .leading, spacing: Spacing.xs) {
                    Text("Sleep after").font(Typography.body).foregroundStyle(Palette.textPrimary)
                    StudioSegmentedControl(KeyboardSettings.SleepTime.allCases, selection: $control.settings.sleepTime) { Text($0.title) }
                        .frame(maxWidth: 420)
                    Text("How long the keyboard waits before sleeping on battery.")
                        .font(Typography.caption)
                        .foregroundStyle(Palette.textTertiary)
                }

                VStack(alignment: .leading, spacing: Spacing.sm) {
                    ToggleRow("Disable Windows / ⌘ key", detail: "Stops accidental presses while gaming", isOn: $control.settings.disableWindowsKey)
                    ToggleRow("Disable Alt + F4", isOn: $control.settings.disableAltF4)
                    ToggleRow("Disable Alt + Tab", isOn: $control.settings.disableAltTab)
                    ToggleRow("Fn switch", detail: "Swaps the top row between F1–F12 and media keys", isOn: $control.settings.fnSwitch)
                }
            }
            .disabled(!control.isAvailable)
            .opacity(control.isAvailable ? 1 : 0.5)
        } accessory: {
            if control.isAvailable {
                WriteStatusPill(status: control.settingsStatus, idle: "Changes apply instantly")
            }
        }
    }
}

/// Keyboard clock sync and the app's time format.
struct TimeSettingsGroup: View {
    @Environment(KeyboardStore.self) private var store
    @AppStorage(PreferenceKey.timeFormat) private var timeFormat = TimeFormatPreference.system.rawValue

    var body: some View {
        @Bindable var control = store.control
        let format = TimeFormatPreference(rawValue: timeFormat) ?? .system

        SettingsGroup("Time") {
            HStack(alignment: .center) {
                VStack(alignment: .leading, spacing: Spacing.xxxs) {
                    Text("Keyboard clock").font(Typography.body).foregroundStyle(Palette.textPrimary)
                    Text(lastSyncDescription(format: format))
                        .font(Typography.caption)
                        .foregroundStyle(Palette.textSecondary)
                }
                Spacer()
                Button {
                    Task { await control.syncClock() }
                } label: {
                    if control.clockStatus == .writing {
                        ProgressView().controlSize(.mini)
                    } else {
                        Label("Sync Now", systemImage: "clock.arrow.2.circlepath")
                    }
                }
                .buttonStyle(.studioSecondary)
                .disabled(!control.isAvailable || control.clockStatus == .writing)
            }
            if case .failed(let message) = control.clockStatus {
                Callout(.danger, title: "Clock sync failed", message: message)
            }

            VStack(alignment: .leading, spacing: Spacing.xs) {
                Text("Keyboard clock format").font(Typography.body).foregroundStyle(Palette.textPrimary)
                StudioSegmentedControl([false, true], selection: $control.keyboardTwelveHour) { Text($0 ? "12-hour" : "24-hour") }
                    .frame(maxWidth: 240)
                    .disabled(!control.isAvailable)
                Text(control.keyboardTwelveHour
                     ? "Shows 10:14 instead of 22:14. The firmware has no AM/PM and counts past 12, so AULA Studio fixes it on every hour while the cable is connected. On Bluetooth or unplugged, it can show 13:00 until the next sync."
                     : "The keyboard's built-in clock style.")
                    .font(Typography.caption)
                    .foregroundStyle(Palette.textTertiary)
                    .fixedSize(horizontal: false, vertical: true)
            }

            ToggleRow("Sync automatically", detail: "Syncs when you plug in the cable, after your Mac wakes, when the time zone changes, and on every hour while connected", isOn: $control.autoSyncClock)

            VStack(alignment: .leading, spacing: Spacing.xs) {
                Text("Time format in the app").font(Typography.body).foregroundStyle(Palette.textPrimary)
                StudioSegmentedControl(TimeFormatPreference.allCases, selection: Binding(
                    get: { format },
                    set: { timeFormat = $0.rawValue }
                )) { Text($0.title) }
                .frame(maxWidth: 360)
                Text("How times appear inside AULA Studio.")
                    .font(Typography.caption)
                    .foregroundStyle(Palette.textTertiary)
            }
        }
    }

    private func lastSyncDescription(format: TimeFormatPreference) -> String {
        if let reason = store.control.unavailableReason, store.control.lastClockSync == nil {
            return reason
        }
        guard let last = store.control.lastClockSync else { return "Not synced yet" }
        let day = Calendar.current.isDateInToday(last) ? "today" : last.formatted(date: .abbreviated, time: .omitted)
        return "Last synced \(day) at \(format.string(from: last))"
    }
}

/// Every HID interface found for the keyboard. It's the first thing to check
/// when a feature is unavailable.
struct DiagnosticsView: View {
    @Environment(KeyboardStore.self) private var store

    var body: some View {
        VStack(alignment: .leading, spacing: Spacing.sm) {
            Text("HID interfaces").font(Typography.body).foregroundStyle(Palette.textPrimary)
            if store.keyboards.isEmpty {
                Text("No AULA interfaces found.").font(Typography.caption).foregroundStyle(Palette.textTertiary)
            }
            ForEach(store.keyboards) { keyboard in
                VStack(alignment: .leading, spacing: Spacing.xs) {
                    HStack {
                        Label(keyboard.kind.title, systemImage: keyboard.kind.symbolName).font(Typography.label)
                        Spacer()
                        Text(capabilitySummary(keyboard)).font(Typography.caption).foregroundStyle(Palette.textSecondary)
                    }
                    ForEach(keyboard.endpoints) { endpoint in
                        HStack(spacing: Spacing.sm) {
                            Text(String(format: "%04X:%04X", endpoint.vendorID, endpoint.productID))
                            Text(String(format: "page 0x%04X/0x%02X", endpoint.usagePage, endpoint.usage))
                            Text("in \(endpoint.maxInputReportSize) · out \(endpoint.maxOutputReportSize) · feat \(endpoint.maxFeatureReportSize)")
                            Spacer()
                            Text(endpoint.role.rawValue)
                                .foregroundStyle(endpoint.role.isConfigurationChannel ? Palette.success : Palette.textSecondary)
                        }
                        .font(Typography.mono)
                        .foregroundStyle(Palette.textSecondary)
                        .textSelection(.enabled)
                    }
                }
                .padding(Spacing.sm)
                .background(Palette.surfaceSunken, in: RoundedRectangle(cornerRadius: Radius.md, style: .continuous))
            }
        }
    }

    private func capabilitySummary(_ keyboard: ConnectedKeyboard) -> String {
        DeviceCapabilities.all.filter { keyboard.capabilities.contains($0.0) }.map(\.1).joined(separator: " · ")
    }
}
