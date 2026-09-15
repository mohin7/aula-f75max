import SwiftUI

/// A dashboard tile with a label, a large value and optional detail.
public struct StatCard<Accessory: View>: View {
    private let title: String
    private let value: String
    private let detail: String?
    private let symbol: String
    private let tint: Color?
    private let accessory: Accessory

    public init(
        _ title: String,
        value: String,
        detail: String? = nil,
        symbol: String,
        tint: Color? = nil,
        @ViewBuilder accessory: () -> Accessory
    ) {
        self.title = title
        self.value = value
        self.detail = detail
        self.symbol = symbol
        self.tint = tint
        self.accessory = accessory()
    }

    public var body: some View {
        StudioCard {
            VStack(alignment: .leading, spacing: Spacing.sm) {
                HStack(spacing: Spacing.xs) {
                    Image(systemName: symbol)
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundStyle(tint ?? Palette.textSecondary)
                        .frame(width: 22, height: 22)
                        .background((tint ?? Palette.textSecondary).opacity(0.12), in: RoundedRectangle(cornerRadius: Radius.xs, style: .continuous))
                    Text(title)
                        .font(Typography.label)
                        .foregroundStyle(Palette.textSecondary)
                        .lineLimit(1)
                    Spacer(minLength: 0)
                    accessory
                }
                Text(value)
                    .font(Typography.title.monospacedDigit())
                    .foregroundStyle(Palette.textPrimary)
                    .lineLimit(1)
                    .minimumScaleFactor(0.7)
                    .contentTransition(.numericText())
                if let detail {
                    Text(detail)
                        .font(Typography.caption)
                        .foregroundStyle(Palette.textTertiary)
                        .lineLimit(2)
                }
            }
        }
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(title)
        .accessibilityValue([value, detail].compactMap { $0 }.joined(separator: ", "))
    }
}

extension StatCard where Accessory == EmptyView {
    public init(_ title: String, value: String, detail: String? = nil, symbol: String, tint: Color? = nil) {
        self.init(title, value: value, detail: detail, symbol: symbol, tint: tint) { EmptyView() }
    }
}

/// A compact status indicator: a colored dot plus a label.
public struct StatusPill: View {
    public enum State { case connected, warning, disconnected, neutral }

    private let label: String
    private let state: State

    public init(_ label: String, state: State) {
        self.label = label
        self.state = state
    }

    private var color: Color {
        switch state {
        case .connected: Palette.success
        case .warning: Palette.warning
        case .disconnected: Palette.danger
        case .neutral: Palette.textTertiary
        }
    }

    public var body: some View {
        HStack(spacing: Spacing.xs) {
            Circle()
                .fill(color)
                .frame(width: 7, height: 7)
                .shadow(color: color.opacity(0.6), radius: state == .connected ? 3 : 0)
            Text(label)
                .font(Typography.label)
                .foregroundStyle(Palette.textPrimary)
        }
        .padding(.horizontal, Spacing.sm)
        .padding(.vertical, Spacing.xxs)
        .background(Palette.surfaceSunken, in: Capsule())
        .overlay { Capsule().strokeBorder(Palette.stroke, lineWidth: 1) }
        .accessibilityElement(children: .combine)
    }
}
