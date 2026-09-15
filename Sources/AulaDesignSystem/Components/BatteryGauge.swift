import SwiftUI

/// Horizontal battery glyph with fill level. `level == nil` means the level is unknown.
public struct BatteryGauge: View {
    private let level: Int?
    private let isCharging: Bool

    public init(level: Int?, isCharging: Bool = false) {
        self.level = level
        self.isCharging = isCharging
    }

    private var tint: Color {
        guard let level else { return Palette.textTertiary }
        if isCharging { return Palette.success }
        switch level {
        case ..<15: return Palette.danger
        case ..<30: return Palette.warning
        default: return Palette.success
        }
    }

    public var body: some View {
        HStack(spacing: 1.5) {
            ZStack(alignment: .leading) {
                RoundedRectangle(cornerRadius: 3.5, style: .continuous)
                    .strokeBorder(Palette.textSecondary.opacity(0.6), lineWidth: 1.2)
                GeometryReader { proxy in
                    RoundedRectangle(cornerRadius: 2, style: .continuous)
                        .fill(tint)
                        .frame(width: max(0, (proxy.size.width) * Double(level ?? 0) / 100))
                }
                .padding(2.2)
                if isCharging {
                    Image(systemName: "bolt.fill")
                        .font(.system(size: 7, weight: .bold))
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity)
                }
            }
            .frame(width: 24, height: 12)
            RoundedRectangle(cornerRadius: 1)
                .fill(Palette.textSecondary.opacity(0.6))
                .frame(width: 1.5, height: 4)
        }
        .accessibilityElement()
        .accessibilityLabel("Battery")
        .accessibilityValue(level.map { "\($0) percent\(isCharging ? ", charging" : "")" } ?? "Unknown")
    }
}
