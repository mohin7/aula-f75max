import AulaDesignSystem
import AulaKit
import SwiftUI

/// Lighting Studio. Edits update the on-screen preview instantly and, over USB-C once set up,
/// the keyboard itself (see `KeyboardControl`).
struct LightingView: View {
    @Environment(KeyboardStore.self) private var store
    @Environment(AppRouter.self) private var router

    private static let presets: [LEDColor] = [
        0xFF3B30, 0xFF9500, 0xFFCC00, 0x34C759, 0x00C7BE, 0x32ADE6, 0x6E7BFF, 0xAF52DE, 0xFF2D55, 0xFFFFFF,
    ].map(LEDColor.init(rgb:))

    var body: some View {
        @Bindable var store = store
        @Bindable var router = router

        HStack(alignment: .top, spacing: 0) {
            ScrollView {
                VStack(alignment: .leading, spacing: Spacing.xl) {
                    VStack(alignment: .leading, spacing: Spacing.xxs) {
                        Text("Lighting").font(Typography.largeTitle).foregroundStyle(Palette.textPrimary)
                        Text("Changes show instantly on the keyboard below.")
                            .font(Typography.body)
                            .foregroundStyle(Palette.textSecondary)
                    }

                    LightingSyncBanner()

                    KeyboardStageCard(selection: $router.selectedKeyIDs)

                    modeGrid(selection: $store.lighting.mode)
                }
                .padding(Spacing.xl)
                .pageContainer(.regular)
            }

            Divider()

            ScrollView {
                controls(lighting: $store.lighting)
                    .padding(Spacing.lg)
            }
            .frame(width: 300)
            .background(Palette.surface)
        }
        .background(Palette.canvas)
    }

    private func modeGrid(selection: Binding<LightingMode>) -> some View {
        VStack(alignment: .leading, spacing: Spacing.sm) {
            SectionHeader("Effects", subtitle: "Built into the keyboard firmware")
            LazyVGrid(columns: [GridItem(.adaptive(minimum: 116), spacing: Spacing.sm)], spacing: Spacing.sm) {
                ForEach(LightingMode.allCases) { mode in
                    ModeTile(mode: mode, isSelected: selection.wrappedValue == mode) {
                        selection.wrappedValue = mode
                    }
                }
            }
        }
    }

    private func controls(lighting: Binding<LightingSettings>) -> some View {
        let mode = lighting.wrappedValue.mode
        return VStack(alignment: .leading, spacing: Spacing.xl) {
            VStack(alignment: .leading, spacing: Spacing.sm) {
                SectionHeader("Color")
                LazyVGrid(columns: Array(repeating: GridItem(.fixed(26), spacing: Spacing.xs), count: 5), alignment: .leading, spacing: Spacing.xs) {
                    ForEach(Self.presets, id: \.self) { preset in
                        ColorSwatch(Color(rgb: preset), isSelected: lighting.wrappedValue.color == preset) {
                            lighting.wrappedValue.color = preset
                        }
                        .accessibilityLabel(preset.hexString)
                    }
                }
                HueStrip(hue: Binding(
                    get: { lighting.wrappedValue.color.hsv.hue },
                    set: { lighting.wrappedValue.color = LEDColor(hsv: HSV(hue: $0, saturation: 1, value: 1)) }
                ))
                HStack(spacing: Spacing.xs) {
                    HexColorField(hex: Binding(
                        get: { lighting.wrappedValue.color.hexString },
                        set: { if let color = LEDColor(hex: $0) { lighting.wrappedValue.color = color } }
                    ))
                    ColorPicker("Custom color", selection: Binding(
                        get: { Color(rgb: lighting.wrappedValue.color) },
                        set: { if let rgb = $0.rgbColor { lighting.wrappedValue.color = rgb } }
                    ), supportsOpacity: false)
                    .labelsHidden()
                }
                ToggleRow("Multicolor", detail: "Use the firmware's rainbow palette", isOn: lighting.multicolor)
            }
            .disabled(!mode.supportsCustomColor)
            .opacity(mode.supportsCustomColor ? 1 : 0.45)

            VStack(alignment: .leading, spacing: Spacing.md) {
                SectionHeader("Adjust")
                StudioSlider("Brightness", level: lighting.brightness, in: LightingSettings.levelRange) { "\($0 * 20)%" }
                StudioSlider("Speed", level: lighting.speed, in: LightingSettings.levelRange)
                    .disabled(!mode.isAnimated)
                    .opacity(mode.isAnimated ? 1 : 0.45)
                if mode.supportsDirection {
                    VStack(alignment: .leading, spacing: Spacing.xs) {
                        Text("Direction").font(Typography.label).foregroundStyle(Palette.textSecondary)
                        StudioSegmentedControl(LightingDirection.allCases, selection: lighting.direction, symbol: \.symbolName) { Text($0.title) }
                            .accessibilityLabel("Direction")
                    }
                }
            }
        }
    }
}

private struct ModeTile: View {
    @Environment(\.studioAccent) private var accent
    let mode: LightingMode
    let isSelected: Bool
    let action: () -> Void

    @State private var isHovered = false

    var body: some View {
        Button(action: action) {
            VStack(alignment: .leading, spacing: Spacing.xs) {
                Image(systemName: mode.symbolName)
                    .font(.system(size: 15, weight: .medium))
                    .frame(height: 20)
                    .foregroundStyle(isSelected ? accent : Palette.textSecondary)
                Text(mode.title)
                    .font(Typography.label)
                    .foregroundStyle(Palette.textPrimary)
                    .lineLimit(1)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(Spacing.sm)
            .background(isSelected ? accent.opacity(0.12) : (isHovered ? Palette.surfaceRaised : Palette.surface),
                        in: RoundedRectangle(cornerRadius: Radius.md, style: .continuous))
            .overlay {
                RoundedRectangle(cornerRadius: Radius.md, style: .continuous)
                    .strokeBorder(isSelected ? accent : Palette.stroke, lineWidth: isSelected ? 1.5 : 1)
            }
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .onHover { isHovered = $0 }
        .animation(Motion.snappy, value: isHovered)
        .accessibilityAddTraits(isSelected ? .isSelected : [])
    }
}

extension Color {
    /// sRGB components, or `nil` for colors that can't be expressed in sRGB (e.g. pattern colors).
    var rgbColor: LEDColor? {
        guard let color = NSColor(self).usingColorSpace(.sRGB) else { return nil }
        return LEDColor(normalizedRed: Double(color.redComponent), green: Double(color.greenComponent), blue: Double(color.blueComponent))
    }
}
