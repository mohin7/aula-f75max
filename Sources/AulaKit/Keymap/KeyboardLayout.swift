import Foundation

/// Geometry in key units ("u"). 1u = the width of a standard alphanumeric key.
public struct KeyRect: Hashable, Codable, Sendable {
    public var x: Double
    public var y: Double
    public var width: Double
    public var height: Double

    public init(x: Double, y: Double, width: Double = 1, height: Double = 1) {
        self.x = x
        self.y = y
        self.width = width
        self.height = height
    }

    public var maxX: Double { x + width }
    public var maxY: Double { y + height }
    public var midX: Double { x + width / 2 }
    public var midY: Double { y + height / 2 }

    public func intersects(_ other: KeyRect) -> Bool {
        x < other.maxX && other.x < maxX && y < other.maxY && other.y < maxY
    }

    public func contains(x px: Double, y py: Double) -> Bool {
        px >= x && px < maxX && py >= y && py < maxY
    }
}

public enum OSLegendMode: String, CaseIterable, Codable, Sendable, Identifiable {
    case mac
    case windows

    public var id: String { rawValue }
    public var title: String { self == .mac ? "Mac" : "Win" }
}

public struct KeyLegend: Hashable, Codable, Sendable {
    public var primary: String
    public var secondary: String?
    /// Overrides for OS-specific modifiers (e.g. "⌘" on Mac, "Win" on Windows).
    public var mac: String?
    public var windows: String?

    public init(_ primary: String, secondary: String? = nil, mac: String? = nil, windows: String? = nil) {
        self.primary = primary
        self.secondary = secondary
        self.mac = mac
        self.windows = windows
    }

    public func text(for mode: OSLegendMode) -> String {
        switch mode {
        case .mac: mac ?? primary
        case .windows: windows ?? primary
        }
    }
}

public struct KeyDefinition: Identifiable, Hashable, Codable, Sendable {
    /// Stable identifier used by keymaps, per-key lighting and profiles. Never reuse.
    public var id: String
    public var legend: KeyLegend
    public var rect: KeyRect
    /// `nil` for keys the firmware handles itself and never sends to the host (Fn).
    public var usage: HIDUsage?
    public var row: Int

    public init(id: String, legend: KeyLegend, rect: KeyRect, usage: HIDUsage?, row: Int) {
        self.id = id
        self.legend = legend
        self.rect = rect
        self.usage = usage
        self.row = row
    }

    public var accessibilityName: String {
        if let usage { return usage.name }
        return legend.primary
    }
}

public struct KnobDefinition: Hashable, Codable, Sendable {
    public var rect: KeyRect
    public var rotateClockwise: HIDUsage
    public var rotateCounterClockwise: HIDUsage
    public var press: HIDUsage

    public init(rect: KeyRect, rotateClockwise: HIDUsage, rotateCounterClockwise: HIDUsage, press: HIDUsage) {
        self.rect = rect
        self.rotateClockwise = rotateClockwise
        self.rotateCounterClockwise = rotateCounterClockwise
        self.press = press
    }
}

public struct DisplayDefinition: Hashable, Codable, Sendable {
    public var rect: KeyRect
    public var pixelWidth: Int
    public var pixelHeight: Int

    public init(rect: KeyRect, pixelWidth: Int, pixelHeight: Int) {
        self.rect = rect
        self.pixelWidth = pixelWidth
        self.pixelHeight = pixelHeight
    }
}

public struct KeyboardLayout: Hashable, Codable, Sendable {
    public var name: String
    public var keys: [KeyDefinition]
    public var knob: KnobDefinition?
    public var display: DisplayDefinition?
    /// Overall plate size in u, excluding the case bezel.
    public var width: Double
    public var height: Double
    /// In Mac mode the firmware swaps what some modifier positions send.
    /// Maps a keyboard-page usage received in Mac mode to the one stored in `keys`
    /// (which uses Windows-mode usages).
    public var macModeUsageRemap: [UInt32: UInt32]

    public init(
        name: String,
        keys: [KeyDefinition],
        knob: KnobDefinition?,
        display: DisplayDefinition?,
        width: Double,
        height: Double,
        macModeUsageRemap: [UInt32: UInt32] = [:]
    ) {
        self.name = name
        self.keys = keys
        self.knob = knob
        self.display = display
        self.width = width
        self.height = height
        self.macModeUsageRemap = macModeUsageRemap
    }

    public func key(id: String) -> KeyDefinition? {
        keys.first { $0.id == id }
    }

    public func key(at x: Double, _ y: Double) -> KeyDefinition? {
        keys.first { $0.rect.contains(x: x, y: y) }
    }

    public func keys(for usage: HIDUsage, mode: OSLegendMode = .windows) -> [KeyDefinition] {
        var usage = usage
        if mode == .mac, usage.page == HIDUsage.Page.keyboard, let mapped = macModeUsageRemap[usage.id] {
            usage.id = mapped
        }
        return keys.filter { $0.usage == usage }
    }

    public func keys(intersecting rect: KeyRect) -> [KeyDefinition] {
        keys.filter { $0.rect.intersects(rect) }
    }
}
