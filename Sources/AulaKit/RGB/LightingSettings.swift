import Foundation

/// Lighting effects built into the F75 Max firmware.
///
/// Raw values are the mode indices the firmware expects. They come from the
/// community protocol notes in `Docs/Hardware-Protocol-Notes.md` and still need
/// checking on hardware in Phase 5.
public enum LightingMode: Int, CaseIterable, Codable, Sendable, Identifiable {
    case off = 0
    case staticColor = 1
    case singleOn = 2
    case singleOff = 3
    case glittering = 4
    case falling = 5
    case colourful = 6
    case breathing = 7
    case spectrum = 8
    case outward = 9
    case scrolling = 10
    case rolling = 11
    case rotating = 12
    case explode = 13
    case launch = 14
    case ripples = 15
    case flowing = 16
    case pulsating = 17
    case tilt = 18
    case shuttle = 19

    public var id: Int { rawValue }

    public var title: String {
        switch self {
        case .off: "Off"
        case .staticColor: "Static"
        case .singleOn: "Reactive"
        case .singleOff: "Reactive Fade"
        case .glittering: "Glitter"
        case .falling: "Rain"
        case .colourful: "Colourful"
        case .breathing: "Breathing"
        case .spectrum: "Spectrum Cycle"
        case .outward: "Outward"
        case .scrolling: "Wave"
        case .rolling: "Rolling"
        case .rotating: "Rotating"
        case .explode: "Explode"
        case .launch: "Launch"
        case .ripples: "Ripple"
        case .flowing: "Flowing"
        case .pulsating: "Pulse"
        case .tilt: "Tilt"
        case .shuttle: "Shuttle"
        }
    }

    public var symbolName: String {
        switch self {
        case .off: "lightbulb.slash"
        case .staticColor: "circle.fill"
        case .singleOn, .singleOff: "hand.tap"
        case .glittering: "sparkles"
        case .falling: "cloud.rain"
        case .colourful: "paintpalette"
        case .breathing: "wind"
        case .spectrum: "rainbow"
        case .outward, .explode: "dot.radiowaves.left.and.right"
        case .scrolling, .flowing: "water.waves"
        case .rolling, .rotating: "arrow.triangle.2.circlepath"
        case .launch: "arrow.up.forward"
        case .ripples: "circle.circle"
        case .pulsating: "waveform.path.ecg"
        case .tilt: "rectangle.portrait.rotate"
        case .shuttle: "arrow.left.and.right"
        }
    }

    /// Whether the effect only lights up in response to key presses.
    public var isReactive: Bool {
        switch self {
        case .singleOn, .singleOff, .ripples, .explode, .launch: true
        default: false
        }
    }

    /// Whether the firmware uses the user-chosen color (vs. its own palette)
    /// when `LightingSettings.multicolor` is off.
    public var supportsCustomColor: Bool { self != .off && self != .spectrum }

    public var supportsDirection: Bool {
        switch self {
        case .scrolling, .rolling, .flowing, .tilt, .shuttle, .falling: true
        default: false
        }
    }

    public var isAnimated: Bool { self != .off && self != .staticColor }
}

public enum LightingDirection: Int, CaseIterable, Codable, Sendable, Identifiable {
    case right = 0
    case down = 1
    case left = 2
    case up = 3

    public var id: Int { rawValue }

    public var title: String {
        switch self {
        case .right: "Right"
        case .down: "Down"
        case .left: "Left"
        case .up: "Up"
        }
    }

    public var symbolName: String {
        switch self {
        case .right: "arrow.right"
        case .down: "arrow.down"
        case .left: "arrow.left"
        case .up: "arrow.up"
        }
    }
}

/// Lighting settings using the firmware's own value ranges, so the UI never
/// offers more precision than the keyboard can actually apply.
public struct LightingSettings: Hashable, Codable, Sendable {
    public static let levelRange = 1...5

    public var mode: LightingMode
    public var color: LEDColor
    /// 1...5
    public var brightness: Int {
        didSet { brightness = brightness.clamped(to: Self.levelRange) }
    }
    /// 1...5
    public var speed: Int {
        didSet { speed = speed.clamped(to: Self.levelRange) }
    }
    public var direction: LightingDirection
    /// Firmware's "colourful" flag: rainbow palette instead of `color`.
    public var multicolor: Bool

    public init(
        mode: LightingMode = .scrolling,
        color: LEDColor = LEDColor(rgb: 0x6E7BFF),
        brightness: Int = 4,
        speed: Int = 3,
        direction: LightingDirection = .right,
        multicolor: Bool = false
    ) {
        self.mode = mode
        self.color = color
        self.brightness = brightness.clamped(to: Self.levelRange)
        self.speed = speed.clamped(to: Self.levelRange)
        self.direction = direction
        self.multicolor = multicolor
    }

    /// 0.2...1.0
    public var brightnessFraction: Double { Double(brightness) / Double(Self.levelRange.upperBound) }
    /// 0.2...1.0
    public var speedFraction: Double { Double(speed) / Double(Self.levelRange.upperBound) }
}

extension Comparable {
    func clamped(to range: ClosedRange<Self>) -> Self {
        min(max(self, range.lowerBound), range.upperBound)
    }
}
