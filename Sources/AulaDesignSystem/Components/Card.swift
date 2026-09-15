import SwiftUI

/// The base surface for grouped content.
public struct StudioCard<Content: View>: View {
    private let radius: CGFloat
    private let padding: CGFloat
    private let content: Content

    public init(radius: CGFloat = Radius.lg, padding: CGFloat = Spacing.md, @ViewBuilder content: () -> Content) {
        self.radius = radius
        self.padding = padding
        self.content = content()
    }

    public var body: some View {
        content
            .padding(padding)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(Palette.surface, in: RoundedRectangle(cornerRadius: radius, style: .continuous))
            .overlay {
                RoundedRectangle(cornerRadius: radius, style: .continuous)
                    .strokeBorder(Palette.stroke, lineWidth: 1)
            }
    }
}

public struct SectionHeader<Accessory: View>: View {
    private let title: String
    private let subtitle: String?
    private let accessory: Accessory

    public init(_ title: String, subtitle: String? = nil, @ViewBuilder accessory: () -> Accessory) {
        self.title = title
        self.subtitle = subtitle
        self.accessory = accessory()
    }

    public var body: some View {
        HStack(alignment: .firstTextBaseline, spacing: Spacing.sm) {
            VStack(alignment: .leading, spacing: Spacing.xxxs) {
                Text(title)
                    .font(Typography.headline)
                    .foregroundStyle(Palette.textPrimary)
                if let subtitle {
                    Text(subtitle)
                        .font(Typography.caption)
                        .foregroundStyle(Palette.textSecondary)
                }
            }
            Spacer(minLength: Spacing.xs)
            accessory
        }
        .accessibilityElement(children: .combine)
        .accessibilityAddTraits(.isHeader)
    }
}

extension SectionHeader where Accessory == EmptyView {
    public init(_ title: String, subtitle: String? = nil) {
        self.init(title, subtitle: subtitle) { EmptyView() }
    }
}

/// Inline notice for capability limits ("Needs USB-C"), permissions and warnings.
public struct Callout: View {
    public enum Tone { case info, warning, danger, success }

    private let tone: Tone
    private let title: String
    private let message: String?
    private let actionTitle: String?
    private let action: (() -> Void)?
    private let onDismiss: (() -> Void)?

    /// - Parameter onDismiss: when set, shows a close button that calls it.
    public init(
        _ tone: Tone,
        title: String,
        message: String? = nil,
        actionTitle: String? = nil,
        action: (() -> Void)? = nil,
        onDismiss: (() -> Void)? = nil
    ) {
        self.tone = tone
        self.title = title
        self.message = message
        self.actionTitle = actionTitle
        self.action = action
        self.onDismiss = onDismiss
    }

    private var color: Color {
        switch tone {
        case .info: Palette.info
        case .warning: Palette.warning
        case .danger: Palette.danger
        case .success: Palette.success
        }
    }

    private var symbol: String {
        switch tone {
        case .info: "info.circle.fill"
        case .warning: "exclamationmark.triangle.fill"
        case .danger: "xmark.octagon.fill"
        case .success: "checkmark.circle.fill"
        }
    }

    public var body: some View {
        HStack(alignment: .top, spacing: Spacing.sm) {
            Image(systemName: symbol)
                .foregroundStyle(color)
                .font(.system(size: 14, weight: .semibold))
                .accessibilityHidden(true)
            VStack(alignment: .leading, spacing: Spacing.xxs) {
                Text(title)
                    .font(Typography.label)
                    .foregroundStyle(Palette.textPrimary)
                if let message {
                    Text(message)
                        .font(Typography.caption)
                        .foregroundStyle(Palette.textSecondary)
                        .fixedSize(horizontal: false, vertical: true)
                }
            }
            Spacer(minLength: 0)
            if let actionTitle, let action {
                Button(actionTitle, action: action)
                    .buttonStyle(.studioSecondary)
                    .controlSize(.small)
            }
            if let onDismiss {
                Button(action: onDismiss) {
                    Image(systemName: "xmark")
                        .font(.system(size: 11, weight: .semibold))
                }
                .buttonStyle(.studioIcon)
                .help("Hide")
                .accessibilityLabel("Hide \(title)")
                .padding(.top, -Spacing.xxs)
                .padding(.trailing, -Spacing.xxs)
            }
        }
        .padding(Spacing.sm)
        .background(color.opacity(0.08), in: RoundedRectangle(cornerRadius: Radius.md, style: .continuous))
        .overlay {
            RoundedRectangle(cornerRadius: Radius.md, style: .continuous)
                .strokeBorder(color.opacity(0.2), lineWidth: 1)
        }
        .accessibilityElement(children: .contain)
    }
}
