import SwiftUI

/// Slider with a label, live value readout and optional discrete steps.
/// Stepped sliders snap and show tick marks, which fits firmware settings like 1–5.
public struct StudioSlider: View {
    @Environment(\.studioAccent) private var accent
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    private let title: String
    @Binding private var value: Double
    private let range: ClosedRange<Double>
    private let step: Double?
    private let format: (Double) -> String

    @State private var isDragging = false

    public init(
        _ title: String,
        value: Binding<Double>,
        in range: ClosedRange<Double>,
        step: Double? = nil,
        format: @escaping (Double) -> String = { String(Int($0.rounded())) }
    ) {
        self.title = title
        self._value = value
        self.range = range
        self.step = step
        self.format = format
    }

    private var fraction: Double {
        (value - range.lowerBound) / (range.upperBound - range.lowerBound)
    }

    public var body: some View {
        VStack(alignment: .leading, spacing: Spacing.xs) {
            HStack {
                Text(title)
                    .font(Typography.label)
                    .foregroundStyle(Palette.textSecondary)
                Spacer()
                Text(format(value))
                    .font(Typography.label.monospacedDigit())
                    .foregroundStyle(Palette.textPrimary)
                    .contentTransition(.numericText())
            }
            GeometryReader { proxy in
                let width = proxy.size.width
                ZStack(alignment: .leading) {
                    Capsule()
                        .fill(Palette.surfaceSunken)
                        .overlay { Capsule().strokeBorder(Palette.stroke, lineWidth: 1) }
                        .frame(height: 6)
                    Capsule()
                        .fill(accent)
                        .frame(width: max(6, width * fraction), height: 6)
                    if let step {
                        let count = Int(((range.upperBound - range.lowerBound) / step).rounded())
                        ForEach(0...count, id: \.self) { index in
                            Circle()
                                .fill(Palette.textTertiary.opacity(0.6))
                                .frame(width: 3, height: 3)
                                .offset(x: width * Double(index) / Double(count) - 1.5)
                        }
                    }
                    Circle()
                        .fill(.white)
                        .frame(width: 16, height: 16)
                        .shadow(color: .black.opacity(0.25), radius: 2, y: 1)
                        .scaleEffect(isDragging ? 1.15 : 1)
                        .offset(x: width * fraction - 8)
                }
                .frame(height: 20)
                .contentShape(Rectangle())
                .gesture(
                    DragGesture(minimumDistance: 0)
                        .onChanged { gesture in
                            isDragging = true
                            update(fraction: gesture.location.x / width)
                        }
                        .onEnded { _ in isDragging = false }
                )
                .animation(Motion.animation(Motion.snappy, reduceMotion: reduceMotion), value: isDragging)
            }
            .frame(height: 20)
        }
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(title)
        .accessibilityValue(format(value))
        .accessibilityAdjustableAction { direction in
            let delta = step ?? (range.upperBound - range.lowerBound) / 20
            switch direction {
            case .increment: value = min(range.upperBound, value + delta)
            case .decrement: value = max(range.lowerBound, value - delta)
            @unknown default: break
            }
        }
    }

    private func update(fraction: Double) {
        var newValue = range.lowerBound + min(max(fraction, 0), 1) * (range.upperBound - range.lowerBound)
        if let step {
            newValue = (newValue / step).rounded() * step
        }
        newValue = min(max(newValue, range.lowerBound), range.upperBound)
        if newValue != value { value = newValue }
    }
}

extension StudioSlider {
    /// Convenience for integer firmware levels.
    public init(_ title: String, level: Binding<Int>, in range: ClosedRange<Int>, format: @escaping (Int) -> String = { "\($0)" }) {
        self.init(
            title,
            value: Binding(get: { Double(level.wrappedValue) }, set: { level.wrappedValue = Int($0.rounded()) }),
            in: Double(range.lowerBound)...Double(range.upperBound),
            step: 1,
            format: { format(Int($0.rounded())) }
        )
    }
}

/// Segmented control with a sliding selection indicator.
public struct StudioSegmentedControl<Option: Hashable>: View {
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @Namespace private var namespace

    private let options: [Option]
    @Binding private var selection: Option
    private let label: (Option) -> Text
    private let symbol: ((Option) -> String)?

    public init(
        _ options: [Option],
        selection: Binding<Option>,
        symbol: ((Option) -> String)? = nil,
        label: @escaping (Option) -> Text
    ) {
        self.options = options
        self._selection = selection
        self.label = label
        self.symbol = symbol
    }

    public var body: some View {
        HStack(spacing: Spacing.xxxs) {
            ForEach(options, id: \.self) { option in
                let isSelected = option == selection
                Button {
                    withAnimation(Motion.animation(Motion.snappy, reduceMotion: reduceMotion)) {
                        selection = option
                    }
                } label: {
                    HStack(spacing: Spacing.xxs) {
                        if let symbol {
                            Image(systemName: symbol(option)).font(.system(size: 11, weight: .semibold))
                        }
                        label(option)
                    }
                    .font(Typography.label)
                    .foregroundStyle(isSelected ? Palette.textPrimary : Palette.textSecondary)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, Spacing.xxs + 1)
                    .background {
                        if isSelected {
                            RoundedRectangle(cornerRadius: Radius.sm - 3, style: .continuous)
                                .fill(Palette.surfaceRaised)
                                .elevation(.raised)
                                .matchedGeometryEffect(id: "selection", in: namespace)
                        }
                    }
                    .contentShape(Rectangle())
                }
                .buttonStyle(.plain)
                .accessibilityAddTraits(isSelected ? .isSelected : [])
            }
        }
        .padding(Spacing.xxxs + 1)
        .background(Palette.surfaceSunken, in: RoundedRectangle(cornerRadius: Radius.sm, style: .continuous))
        .overlay {
            RoundedRectangle(cornerRadius: Radius.sm, style: .continuous).strokeBorder(Palette.stroke, lineWidth: 1)
        }
    }
}

/// A settings row: title, optional detail, and a trailing switch.
public struct ToggleRow: View {
    private let title: String
    private let detail: String?
    @Binding private var isOn: Bool

    public init(_ title: String, detail: String? = nil, isOn: Binding<Bool>) {
        self.title = title
        self.detail = detail
        self._isOn = isOn
    }

    public var body: some View {
        HStack(alignment: .center, spacing: Spacing.md) {
            VStack(alignment: .leading, spacing: Spacing.xxxs) {
                Text(title).font(Typography.body).foregroundStyle(Palette.textPrimary)
                if let detail {
                    Text(detail).font(Typography.caption).foregroundStyle(Palette.textSecondary)
                }
            }
            Spacer(minLength: Spacing.md)
            Toggle(title, isOn: $isOn)
                .labelsHidden()
                .toggleStyle(.switch)
                .controlSize(.small)
        }
        .contentShape(Rectangle())
        .onTapGesture { isOn.toggle() }
        .accessibilityElement(children: .combine)
    }
}
