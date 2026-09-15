import AulaDesignSystem
import AulaKit
import SwiftUI

/// Floating panel for the selected key. Remapping and per-key lighting controls
/// go here in Phases 5 and 7; for now it shows the identity and live state.
struct KeyInspector: View {
    @Environment(KeyboardStore.self) private var store
    let key: KeyDefinition
    let onClose: () -> Void

    var body: some View {
        FloatingInspector(key.accessibilityName, subtitle: "Row \(key.row + 1)", onClose: onClose) {
            HStack {
                Spacer()
                KeyCapView(
                    legend: key.legend.text(for: store.legendMode),
                    secondary: key.legend.secondary,
                    glow: Color(rgb: store.lighting.mode == .off ? .black : store.lighting.color).opacity(0.6),
                    unitWidth: min(key.rect.width, 2.25),
                    isSelected: store.pressedKeyIDs.contains(key.id)
                )
                Spacer()
            }
            .padding(.vertical, Spacing.xs)

            VStack(spacing: Spacing.xs) {
                PropertyRow("Key ID", value: key.id, monospaced: true)
                PropertyRow("HID usage", value: key.usage?.description ?? "Firmware (not sent)", monospaced: true)
                PropertyRow("Size", value: String(format: "%.2gu", key.rect.width))
                PropertyRow("Tested", value: store.testedKeyIDs.contains(key.id) ? "Yes" : "Not yet")
            }

            Divider()

            VStack(alignment: .leading, spacing: Spacing.xs) {
                Text("Coming next").font(Typography.eyebrow).foregroundStyle(Palette.textTertiary).textCase(.uppercase)
                Label("Per-key color and effect · Phase 5", systemImage: "paintbrush.pointed")
                Label("Remap, macro or shortcut · Phase 7", systemImage: "arrow.triangle.swap")
            }
            .font(Typography.caption)
            .foregroundStyle(Palette.textSecondary)
        }
    }
}

/// Live event log plus layout coverage. Press every key once to check that the
/// on-screen layout matches the hardware.
struct KeyTesterCard: View {
    @Environment(KeyboardStore.self) private var store

    var body: some View {
        StudioCard(radius: Radius.xl, padding: Spacing.lg) {
            VStack(alignment: .leading, spacing: Spacing.md) {
                SectionHeader(
                    "Key Tester",
                    subtitle: "\(store.testedKeyIDs.count) of \(store.layout.keys.filter { $0.usage != nil }.count) keys verified. A key that lights up in the wrong place means the layout needs fixing."
                ) {
                    Button("Reset") { store.resetKeyTester() }
                        .buttonStyle(.studioSecondary)
                        .controlSize(.small)
                }

                ProgressView(
                    value: Double(store.testedKeyIDs.count),
                    total: Double(max(1, store.layout.keys.filter { $0.usage != nil }.count))
                )
                .tint(Palette.success)

                if store.recentEvents.isEmpty {
                    Text(store.inputAccess == .granted ? "Press any key on your F75 Max…" : "Allow Input Monitoring to see key events.")
                        .font(Typography.body)
                        .foregroundStyle(Palette.textTertiary)
                        .frame(maxWidth: .infinity, alignment: .center)
                        .padding(.vertical, Spacing.lg)
                } else {
                    VStack(spacing: 0) {
                        ForEach(store.recentEvents) { event in
                            HStack(spacing: Spacing.sm) {
                                Text(event.usage.description)
                                    .font(Typography.mono)
                                    .foregroundStyle(Palette.textTertiary)
                                    .frame(width: 96, alignment: .leading)
                                Text(event.usage.name)
                                    .font(Typography.label)
                                    .foregroundStyle(Palette.textPrimary)
                                Spacer()
                                if let keyID = event.keyID {
                                    Text(keyID).font(Typography.mono).foregroundStyle(Palette.textSecondary)
                                } else if event.usage.page == HIDUsage.Page.consumer {
                                    Text("knob / media").font(Typography.caption).foregroundStyle(Palette.info)
                                } else {
                                    Text("not in layout").font(Typography.caption).foregroundStyle(Palette.warning)
                                }
                            }
                            .padding(.vertical, Spacing.xxs + 2)
                            Divider().opacity(0.5)
                        }
                    }
                }
            }
        }
    }
}
