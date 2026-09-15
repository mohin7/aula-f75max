import SwiftUI

/// Rotary dial control: drag vertically or scroll to change the value.
/// Shaped like the keyboard knob so the metaphor carries across.
public struct KnobDial: View {
    @Environment(\.studioAccent) private var accent

    private let title: String
    @Binding private var value: Double
    private let range: ClosedRange<Double>
    private let format: (Double) -> String

    @State private var dragStart: Double?

    /// The arc spans 270°, from 135° to 405°.
    private let sweep = 270.0

    public init(_ title: String, value: Binding<Double>, in range: ClosedRange<Double>, format: @escaping (Double) -> String = { "\(Int($0.rounded()))" }) {
        self.title = title
        self._value = value
        self.range = range
        self.format = format
    }

    private var fraction: Double {
        (value - range.lowerBound) / (range.upperBound - range.lowerBound)
    }

    public var body: some View {
        VStack(spacing: Spacing.xs) {
            ZStack {
                Circle()
                    .trim(from: 0, to: sweep / 360)
                    .stroke(Palette.surfaceSunken, style: StrokeStyle(lineWidth: 4, lineCap: .round))
                    .rotationEffect(.degrees(135))
                Circle()
                    .trim(from: 0, to: sweep / 360 * fraction)
                    .stroke(accent, style: StrokeStyle(lineWidth: 4, lineCap: .round))
                    .rotationEffect(.degrees(135))
                KnobFace(angle: .degrees(-135 + sweep * fraction))
                    .padding(Spacing.xs)
            }
            .frame(width: 64, height: 64)
            .contentShape(Circle())
            .gesture(
                DragGesture(minimumDistance: 0)
                    .onChanged { gesture in
                        let start = dragStart ?? value
                        dragStart = start
                        let delta = -gesture.translation.height / 150 * (range.upperBound - range.lowerBound)
                        value = min(max(start + delta, range.lowerBound), range.upperBound)
                    }
                    .onEnded { _ in dragStart = nil }
            )
            VStack(spacing: 0) {
                Text(format(value)).font(Typography.label.monospacedDigit()).foregroundStyle(Palette.textPrimary)
                Text(title).font(Typography.caption).foregroundStyle(Palette.textSecondary)
            }
        }
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(title)
        .accessibilityValue(format(value))
        .accessibilityAdjustableAction { direction in
            let step = (range.upperBound - range.lowerBound) / 20
            value = min(max(value + (direction == .increment ? step : -step), range.lowerBound), range.upperBound)
        }
    }
}

/// Knurled metal knob face. Also used by the keyboard visualization.
public struct KnobFace: View {
    private let angle: Angle
    private let isPressed: Bool

    public init(angle: Angle, isPressed: Bool = false) {
        self.angle = angle
        self.isPressed = isPressed
    }

    public var body: some View {
        GeometryReader { proxy in
            let size = min(proxy.size.width, proxy.size.height)
            ZStack {
                Circle()
                    .fill(
                        AngularGradient(
                            colors: [Color(hex: 0x9A9CA3), Color(hex: 0x5C5E66), Color(hex: 0xC4C6CC), Color(hex: 0x55575E), Color(hex: 0x9A9CA3)],
                            center: .center
                        )
                    )
                // Knurling ticks
                ForEach(0..<36, id: \.self) { index in
                    Rectangle()
                        .fill(Color.black.opacity(0.25))
                        .frame(width: max(0.6, size * 0.012), height: size * 0.08)
                        .offset(y: -size * 0.46)
                        .rotationEffect(.degrees(Double(index) * 10))
                }
                Circle()
                    .fill(
                        RadialGradient(colors: [Color(hex: 0x3A3B40), Color(hex: 0x232428)], center: .topLeading, startRadius: 0, endRadius: size)
                    )
                    .padding(size * 0.12)
                Capsule()
                    .fill(Color.white.opacity(0.85))
                    .frame(width: max(1.5, size * 0.05), height: size * 0.18)
                    .offset(y: -size * 0.25)
            }
            .rotationEffect(angle)
            .scaleEffect(isPressed ? 0.94 : 1)
            .frame(width: size, height: size)
            .position(x: proxy.size.width / 2, y: proxy.size.height / 2)
        }
        .accessibilityHidden(true)
    }
}
