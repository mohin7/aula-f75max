import SwiftUI

public struct StudioPrimaryButtonStyle: ButtonStyle {
    @Environment(\.studioAccent) private var accent
    @Environment(\.isEnabled) private var isEnabled
    @Environment(\.controlSize) private var controlSize

    public init() {}

    public func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(Typography.label)
            .foregroundStyle(.white)
            .padding(.horizontal, controlSize == .small ? Spacing.sm : Spacing.md)
            .padding(.vertical, controlSize == .small ? Spacing.xxs : Spacing.xs)
            .background(accent.opacity(isEnabled ? 1 : 0.4), in: RoundedRectangle(cornerRadius: Radius.sm, style: .continuous))
            .overlay {
                RoundedRectangle(cornerRadius: Radius.sm, style: .continuous)
                    .strokeBorder(.white.opacity(0.18), lineWidth: 1)
            }
            .brightness(configuration.isPressed ? -0.08 : 0)
            .scaleEffect(configuration.isPressed ? 0.98 : 1)
            .animation(Motion.snappy, value: configuration.isPressed)
    }
}

public struct StudioSecondaryButtonStyle: ButtonStyle {
    @Environment(\.controlSize) private var controlSize

    public init() {}

    public func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(Typography.label)
            .foregroundStyle(Palette.textPrimary)
            .padding(.horizontal, controlSize == .small ? Spacing.sm : Spacing.md)
            .padding(.vertical, controlSize == .small ? Spacing.xxs : Spacing.xs)
            .background(Palette.surfaceSunken, in: RoundedRectangle(cornerRadius: Radius.sm, style: .continuous))
            .overlay {
                RoundedRectangle(cornerRadius: Radius.sm, style: .continuous)
                    .strokeBorder(Palette.stroke, lineWidth: 1)
            }
            .opacity(configuration.isPressed ? 0.75 : 1)
            .animation(Motion.snappy, value: configuration.isPressed)
    }
}

/// Borderless icon button for toolbars and inspectors.
public struct StudioIconButtonStyle: ButtonStyle {
    @State private var isHovered = false

    public init() {}

    public func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.system(size: 13, weight: .medium))
            .foregroundStyle(Palette.textSecondary)
            .frame(width: 28, height: 28)
            .background(
                Palette.strokeStrong.opacity(configuration.isPressed ? 1 : (isHovered ? 0.6 : 0)),
                in: RoundedRectangle(cornerRadius: Radius.sm, style: .continuous)
            )
            .contentShape(Rectangle())
            .onHover { isHovered = $0 }
            .animation(Motion.snappy, value: isHovered)
    }
}

extension ButtonStyle where Self == StudioPrimaryButtonStyle {
    public static var studioPrimary: StudioPrimaryButtonStyle { .init() }
}

extension ButtonStyle where Self == StudioSecondaryButtonStyle {
    public static var studioSecondary: StudioSecondaryButtonStyle { .init() }
}

extension ButtonStyle where Self == StudioIconButtonStyle {
    public static var studioIcon: StudioIconButtonStyle { .init() }
}
