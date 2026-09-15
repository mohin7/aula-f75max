import AppKit
import AulaDesignSystem
import AulaKit
import SwiftUI

/// Compact companion in the menu bar: status plus the most-used controls.
struct MenuBarView: View {
    @Environment(KeyboardStore.self) private var store
    @Environment(\.openWindow) private var openWindow

    var body: some View {
        @Bindable var store = store

        VStack(alignment: .leading, spacing: Spacing.md) {
            HStack(spacing: Spacing.sm) {
                Image(systemName: "keyboard")
                    .font(.system(size: 16, weight: .medium))
                    .frame(width: 32, height: 32)
                    .background(Palette.surfaceSunken, in: RoundedRectangle(cornerRadius: Radius.sm, style: .continuous))
                VStack(alignment: .leading, spacing: 0) {
                    Text(store.primary?.productName ?? store.layout.name).font(Typography.headline)
                    Text(store.primary.map { "Connected · \($0.kind.title)" } ?? "Not connected")
                        .font(Typography.caption)
                        .foregroundStyle(store.isConnected ? Palette.success : Palette.textSecondary)
                }
                Spacer()
                HStack(spacing: Spacing.xxs) {
                    if let level = store.displayedBatteryLevel {
                        Text("\(level)%")
                            .font(Typography.label.monospacedDigit())
                            .foregroundStyle(store.isBatteryLevelLive ? Palette.textPrimary : Palette.textTertiary)
                    }
                    BatteryGauge(level: store.displayedBatteryLevel, isCharging: store.isCharging)
                }
            }

            StudioSlider("Brightness", level: $store.lighting.brightness, in: LightingSettings.levelRange) { "\($0 * 20)%" }

            Picker("Effect", selection: $store.lighting.mode) {
                ForEach(LightingMode.allCases) { mode in
                    Label(mode.title, systemImage: mode.symbolName).tag(mode)
                }
            }

            if !store.control.isAvailable {
                Text("Preview only. Connect USB-C to change the keyboard's lighting.")
                    .font(Typography.caption)
                    .foregroundStyle(Palette.textTertiary)
            }

            if store.control.isAvailable {
                Button {
                    Task { await store.control.syncClock() }
                } label: {
                    Label("Sync Keyboard Clock", systemImage: "clock.arrow.2.circlepath")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.studioSecondary)
                .disabled(store.control.clockStatus == .writing)
            }

            Divider()

            HStack {
                Button("Open AULA Studio") {
                    openWindow(id: AULAStudioApp.mainWindowID)
                    NSApp.activate()
                }
                .buttonStyle(.studioPrimary)
                Spacer()
                Button("Quit") { NSApp.terminate(nil) }
                    .buttonStyle(.studioSecondary)
            }
        }
        .padding(Spacing.md)
        .frame(width: 300)
    }
}
