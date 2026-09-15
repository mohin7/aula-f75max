import SwiftUI

/// Type scale built on SF Pro. `.system` picks SF Pro Display or Text by optical size,
/// and text styles keep Dynamic Type and accessibility scaling working.
public enum Typography {
    /// Large title (26 pt on macOS), semibold: page titles.
    public static let largeTitle = Font.system(.largeTitle, design: .default).weight(.semibold)
    /// Title 2 (17 pt), semibold: card values.
    public static let title = Font.system(.title2, design: .default).weight(.semibold)
    /// Headline (13 pt semibold): card and section titles.
    public static let headline = Font.system(.headline, design: .default)
    /// Body (13 pt): text.
    public static let body = Font.system(.body, design: .default)
    /// Callout (12 pt), medium: control labels.
    public static let label = Font.system(.callout, design: .default).weight(.medium)
    /// Caption (10 pt): supporting detail.
    public static let caption = Font.system(.caption, design: .default)
    /// Tabular digits for live numbers, so values don't jitter as they change.
    public static let metric = Font.system(.title, design: .rounded).weight(.semibold).monospacedDigit()
    /// Hex, HID usages, byte dumps.
    public static let mono = Font.system(.callout, design: .monospaced)
    /// Uppercase eyebrow above a section.
    public static let eyebrow = Font.system(.caption2, design: .default).weight(.semibold)
}
