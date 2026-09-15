import AppKit
import SwiftUI

/// Semantic colors. Neutral by default; the only saturated color is the accent,
/// which usually comes from the keyboard's current RGB.
public enum Palette {
    public static let canvas = dynamic(light: 0xF5F5F7, dark: 0x0E0E10)
    public static let surface = dynamic(light: 0xFFFFFF, dark: 0x18181B)
    public static let surfaceRaised = dynamic(light: 0xFFFFFF, dark: 0x1F1F23)
    public static let surfaceSunken = dynamic(light: 0xEDEDF0, dark: 0x111113)
    public static let stroke = dynamic(light: 0x000000, dark: 0xFFFFFF, lightAlpha: 0.08, darkAlpha: 0.08)
    public static let strokeStrong = dynamic(light: 0x000000, dark: 0xFFFFFF, lightAlpha: 0.16, darkAlpha: 0.18)

    public static let textPrimary = dynamic(light: 0x1D1D1F, dark: 0xF5F5F7)
    public static let textSecondary = dynamic(light: 0x6E6E73, dark: 0xA1A1AA)
    public static let textTertiary = dynamic(light: 0xA1A1A6, dark: 0x6B6B73)

    public static let success = dynamic(light: 0x1F9D55, dark: 0x34D399)
    public static let warning = dynamic(light: 0xC77700, dark: 0xFBBF24)
    public static let danger = dynamic(light: 0xD92D20, dark: 0xF87171)
    public static let info = dynamic(light: 0x2563EB, dark: 0x60A5FA)

    /// Keyboard stage colors (anodized aluminum case, PBT caps). They stay dark in both themes on purpose.
    public static let caseTop = Color(hex: 0x2A2B30)
    public static let caseBottom = Color(hex: 0x17181B)
    public static let keycapFace = Color(hex: 0x2C2D32)
    public static let keycapSkirt = Color(hex: 0x1B1C20)
    public static let keycapLegend = Color(hex: 0xE8E8EC)

    /// Light and dark hex values need the same alpha unless overridden.
    static func dynamic(
        light: UInt32,
        dark: UInt32,
        lightAlpha: CGFloat = 1,
        darkAlpha: CGFloat = 1
    ) -> Color {
        Color(nsColor: NSColor(name: nil) { appearance in
            let isDark = appearance.bestMatch(from: [.darkAqua, .aqua, .accessibilityHighContrastDarkAqua, .accessibilityHighContrastAqua])
                .map { $0 == .darkAqua || $0 == .accessibilityHighContrastDarkAqua } ?? false
            return NSColor(hex: isDark ? dark : light, alpha: isDark ? darkAlpha : lightAlpha)
        })
    }
}

extension NSColor {
    convenience init(hex: UInt32, alpha: CGFloat = 1) {
        self.init(
            srgbRed: CGFloat((hex >> 16) & 0xFF) / 255,
            green: CGFloat((hex >> 8) & 0xFF) / 255,
            blue: CGFloat(hex & 0xFF) / 255,
            alpha: alpha
        )
    }
}

extension Color {
    public init(hex: UInt32, opacity: Double = 1) {
        self.init(
            .sRGB,
            red: Double((hex >> 16) & 0xFF) / 255,
            green: Double((hex >> 8) & 0xFF) / 255,
            blue: Double(hex & 0xFF) / 255,
            opacity: opacity
        )
    }
}

// MARK: - Accent

private struct StudioAccentKey: EnvironmentKey {
    static let defaultValue = Color(hex: 0x6E7BFF)
}

extension EnvironmentValues {
    /// Brand accent for the app. Usually follows the keyboard lighting color.
    public var studioAccent: Color {
        get { self[StudioAccentKey.self] }
        set { self[StudioAccentKey.self] = newValue }
    }
}
