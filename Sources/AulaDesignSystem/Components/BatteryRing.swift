import SwiftUI

/// Circular battery gauge with the percentage in the middle.
/// `level == nil` draws a dashed ring for "unknown".
public struct BatteryRing: View {
    private let level: Int?
    private let isPluggedIn: Bool
    private let isStale: Bool
    private let lineWidth: CGFloat

    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    /// - Parameters:
    ///   - isStale: dims the ring when the value is a remembered reading, not a live one.
    public init(level: Int?, isPluggedIn: Bool = false, isStale: Bool = false, lineWidth: CGFloat = 7) {
        self.level = level
        self.isPluggedIn = isPluggedIn
        self.isStale = isStale
        self.lineWidth = lineWidth
    }

    public static func tint(for level: Int?, isPluggedIn: Bool) -> Color {
        guard let level else { return Palette.textTertiary }
        if isPluggedIn { return Palette.success }
        switch level {
        case ..<15: return Palette.danger
        case ..<30: return Palette.warning
        default: return Palette.success
        }
    }

    public var body: some View {
        let tint = Self.tint(for: level, isPluggedIn: isPluggedIn)
        GeometryReader { proxy in
            let size = min(proxy.size.width, proxy.size.height)
            ZStack {
                Circle()
                    .stroke(Palette.surfaceSunken, style: StrokeStyle(lineWidth: lineWidth))
                if let level {
                    Circle()
                        .trim(from: 0, to: CGFloat(level) / 100)
                        .stroke(tint.opacity(isStale ? 0.45 : 1), style: StrokeStyle(lineWidth: lineWidth, lineCap: .round))
                        .rotationEffect(.degrees(-90))
                        .animation(Motion.animation(Motion.gentle, reduceMotion: reduceMotion), value: level)
                } else {
                    Circle()
                        .stroke(Palette.textTertiary.opacity(0.5), style: StrokeStyle(lineWidth: lineWidth / 2, dash: [3, 4]))
                }
                VStack(spacing: 0) {
                    if isPluggedIn {
                        Image(systemName: "bolt.fill")
                            .font(.system(size: size * 0.16, weight: .bold))
                            .foregroundStyle(Palette.success)
                    }
                    Text(level.map { "\($0)" } ?? "—")
                        .font(.system(size: size * (isPluggedIn ? 0.26 : 0.3), weight: .semibold, design: .rounded).monospacedDigit())
                        .foregroundStyle(isStale ? Palette.textSecondary : Palette.textPrimary)
                        .contentTransition(.numericText())
                    if level != nil {
                        Text("%")
                            .font(.system(size: size * 0.12, weight: .semibold, design: .rounded))
                            .foregroundStyle(Palette.textTertiary)
                    }
                }
            }
            .frame(width: size, height: size)
            .position(x: proxy.size.width / 2, y: proxy.size.height / 2)
        }
        .accessibilityElement()
        .accessibilityLabel("Battery")
        .accessibilityValue(accessibilityValue)
    }

    private var accessibilityValue: String {
        guard let level else { return "Unknown" }
        var parts = ["\(level) percent"]
        if isPluggedIn { parts.append("plugged in") }
        if isStale { parts.append("last known reading") }
        return parts.joined(separator: ", ")
    }
}
