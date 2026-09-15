import SwiftUI

/// Floating material panel for contextual editing, such as a selected key.
public struct FloatingInspector<Content: View>: View {
    private let title: String
    private let subtitle: String?
    private let onClose: (() -> Void)?
    private let content: Content

    public init(_ title: String, subtitle: String? = nil, onClose: (() -> Void)? = nil, @ViewBuilder content: () -> Content) {
        self.title = title
        self.subtitle = subtitle
        self.onClose = onClose
        self.content = content()
    }

    public var body: some View {
        VStack(alignment: .leading, spacing: Spacing.md) {
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: Spacing.xxxs) {
                    Text(title).font(Typography.headline).foregroundStyle(Palette.textPrimary)
                    if let subtitle {
                        Text(subtitle).font(Typography.caption).foregroundStyle(Palette.textSecondary)
                    }
                }
                Spacer()
                if let onClose {
                    Button(action: onClose) {
                        Image(systemName: "xmark")
                    }
                    .buttonStyle(.studioIcon)
                    .keyboardShortcut(.cancelAction)
                    .accessibilityLabel("Close inspector")
                }
            }
            content
        }
        .padding(Spacing.md)
        .frame(width: 280, alignment: .leading)
        .background(.regularMaterial, in: RoundedRectangle(cornerRadius: Radius.xl, style: .continuous))
        .overlay {
            RoundedRectangle(cornerRadius: Radius.xl, style: .continuous).strokeBorder(Palette.stroke, lineWidth: 1)
        }
        .elevation(.floating)
        .accessibilityElement(children: .contain)
        .accessibilityLabel(title)
    }
}

/// A label/value row for inspectors.
public struct PropertyRow: View {
    private let label: String
    private let value: String
    private let monospaced: Bool

    public init(_ label: String, value: String, monospaced: Bool = false) {
        self.label = label
        self.value = value
        self.monospaced = monospaced
    }

    public var body: some View {
        HStack {
            Text(label).font(Typography.caption).foregroundStyle(Palette.textSecondary)
            Spacer()
            Text(value)
                .font(monospaced ? Typography.mono : Typography.label)
                .foregroundStyle(Palette.textPrimary)
                .textSelection(.enabled)
        }
        .accessibilityElement(children: .combine)
    }
}

/// A single keycap, drawn as a view. The keyboard canvas draws caps with Canvas
/// for speed; this version is for inspectors, keymap palettes and drag previews.
public struct KeyCapView: View {
    private let legend: String
    private let secondary: String?
    private let glow: Color
    private let unitWidth: Double
    private let isSelected: Bool

    @Environment(\.studioAccent) private var accent

    public init(legend: String, secondary: String? = nil, glow: Color = .clear, unitWidth: Double = 1, isSelected: Bool = false) {
        self.legend = legend
        self.secondary = secondary
        self.glow = glow
        self.unitWidth = unitWidth
        self.isSelected = isSelected
    }

    public var body: some View {
        let unit: CGFloat = 56
        ZStack {
            RoundedRectangle(cornerRadius: Radius.sm, style: .continuous)
                .fill(Palette.keycapSkirt)
                .shadow(color: glow.opacity(0.9), radius: 10)
            RoundedRectangle(cornerRadius: Radius.xs + 1, style: .continuous)
                .fill(LinearGradient(colors: [Palette.keycapFace.opacity(1), Palette.keycapFace.opacity(0.85)], startPoint: .top, endPoint: .bottom))
                .padding(.horizontal, 5)
                .padding(.top, 3)
                .padding(.bottom, 8)
            VStack(spacing: 0) {
                if let secondary {
                    Text(secondary).font(.system(size: 10, weight: .medium)).opacity(0.6)
                }
                Text(legend).font(.system(size: 14, weight: .medium))
            }
            .foregroundStyle(Palette.keycapLegend)
            .shadow(color: glow, radius: 4)
            .offset(y: -2)
        }
        .frame(width: unit * unitWidth, height: unit)
        .overlay {
            if isSelected {
                RoundedRectangle(cornerRadius: Radius.sm + 3, style: .continuous)
                    .strokeBorder(accent, lineWidth: 2)
                    .padding(-3)
            }
        }
        .accessibilityElement()
        .accessibilityLabel(legend.isEmpty ? "Space" : legend)
    }
}
