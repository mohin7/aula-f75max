import SwiftUI

/// 4-pt spacing grid. Prefer tokens over literals so rhythm stays consistent.
public enum Spacing {
    public static let xxxs: CGFloat = 2
    public static let xxs: CGFloat = 4
    public static let xs: CGFloat = 8
    public static let sm: CGFloat = 12
    public static let md: CGFloat = 16
    public static let lg: CGFloat = 20
    public static let xl: CGFloat = 24
    public static let xxl: CGFloat = 32
    public static let xxxl: CGFloat = 48

    public static let all: [CGFloat] = [xxs, xs, sm, md, lg, xl, xxl, xxxl]
}

/// Corner radii. Continuous corners everywhere.
public enum Radius {
    /// Keycaps, small chips.
    public static let xs: CGFloat = 6
    /// Buttons, text fields, segmented controls.
    public static let sm: CGFloat = 10
    /// Rows, inner panels.
    public static let md: CGFloat = 14
    /// Standard cards.
    public static let lg: CGFloat = 18
    /// Inspectors, popovers, palettes.
    public static let xl: CGFloat = 24
    /// Hero surfaces: the keyboard stage.
    public static let xxl: CGFloat = 32
}

/// Motion presets. Every animation goes through `Motion.animation(_:reduceMotion:)`
/// so Reduce Motion works everywhere.
public enum Motion {
    /// Hover, press, selection. Must feel instant.
    public static let snappy = Animation.spring(response: 0.22, dampingFraction: 0.86)
    /// Panels, inspectors, navigation changes.
    public static let smooth = Animation.spring(response: 0.36, dampingFraction: 0.9)
    /// Large layout changes.
    public static let gentle = Animation.spring(response: 0.5, dampingFraction: 0.92)

    public static func animation(_ animation: Animation, reduceMotion: Bool) -> Animation {
        reduceMotion ? .linear(duration: 0.01) : animation
    }
}

public enum Elevation {
    case flat, raised, floating

    var radius: CGFloat {
        switch self {
        case .flat: 0
        case .raised: 12
        case .floating: 32
        }
    }

    var y: CGFloat {
        switch self {
        case .flat: 0
        case .raised: 4
        case .floating: 16
        }
    }

    var opacity: Double {
        switch self {
        case .flat: 0
        case .raised: 0.08
        case .floating: 0.18
        }
    }
}

extension View {
    public func elevation(_ level: Elevation) -> some View {
        shadow(color: .black.opacity(level.opacity), radius: level.radius, x: 0, y: level.y)
    }
}

/// Page widths. Every page's content sits in a centered column capped at one of these.
public enum PageWidth {
    /// Dashboards with a keyboard and card grids.
    case wide
    /// Editors with a canvas plus an inspector.
    case regular
    /// Forms and settings, where long lines hurt readability.
    case readable

    public var points: CGFloat {
        switch self {
        case .wide: 1280
        case .regular: 1080
        case .readable: 820
        }
    }
}

extension View {
    /// Caps the content at `width`, centers the column in the available space and keeps
    /// text left-aligned inside it. Apply it to a page's content, inside its ScrollView.
    public func pageContainer(_ width: PageWidth) -> some View {
        frame(maxWidth: width.points, alignment: .leading)
            .frame(maxWidth: .infinity, alignment: .center)
    }
}
