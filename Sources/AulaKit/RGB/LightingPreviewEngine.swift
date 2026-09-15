import Foundation

/// Approximates the firmware lighting effects on screen so the preview reacts
/// instantly. It's a pure function of (settings, key position, time, press age),
/// which makes it deterministic and unit-testable.
///
/// It only approximates what the firmware renders. Phase 5 calibrates each mode
/// against the real keyboard.
public struct LightingPreviewEngine: Sendable {
    public var settings: LightingSettings
    /// Plate size in u, used to normalize positions.
    public var boardWidth: Double
    public var boardHeight: Double

    public init(settings: LightingSettings, boardWidth: Double, boardHeight: Double) {
        self.settings = settings
        self.boardWidth = boardWidth
        self.boardHeight = boardHeight
    }

    /// How long a reactive highlight stays visible.
    public static let reactiveDecay: Double = 0.9

    /// A recent key press, used as the origin for radiating effects.
    public struct Press: Hashable, Sendable {
        public var x: Double
        public var y: Double
        public var age: Double

        public init(x: Double, y: Double, age: Double) {
            self.x = x
            self.y = y
            self.age = age
        }
    }

    /// - Parameters:
    ///   - x, y: key center in u.
    ///   - time: seconds since any fixed reference.
    ///   - pressAge: seconds since the key was last pressed, or `nil` if never.
    ///   - seed: stable per-key value in 0..<1 for effects with randomness.
    ///   - presses: recent presses anywhere on the board, for ripple-style effects.
    public func color(
        x: Double,
        y: Double,
        time: Double,
        pressAge: Double?,
        seed: Double,
        presses: [Press] = []
    ) -> LEDColor {
        let nx = x / boardWidth
        let ny = y / boardHeight
        let speed = 0.35 + settings.speedFraction * 1.4
        let t = time * speed
        let base = settings.color
        let level = settings.brightnessFraction

        func palette(_ phase: Double) -> LEDColor {
            settings.multicolor ? LEDColor(hsv: HSV(hue: phase * 360, saturation: 1, value: 1)) : base
        }

        func along(_ nx: Double, _ ny: Double) -> Double {
            switch settings.direction {
            case .right: nx
            case .left: 1 - nx
            case .down: ny
            case .up: 1 - ny
            }
        }

        func reactive(_ age: Double?) -> Double {
            guard let age, age >= 0, age < Self.reactiveDecay else { return 0 }
            return 1 - age / Self.reactiveDecay
        }

        let intensity: Double
        let color: LEDColor

        switch settings.mode {
        case .off:
            return .black

        case .staticColor:
            color = base
            intensity = 1

        case .breathing:
            color = settings.multicolor ? palette(floor(t / (2 * .pi)) * 0.17) : base
            intensity = 0.08 + 0.92 * (0.5 - 0.5 * cos(t * 2))

        case .spectrum:
            color = LEDColor(hsv: HSV(hue: t * 40, saturation: 1, value: 1))
            intensity = 1

        case .colourful:
            color = LEDColor(hsv: HSV(hue: (nx * 0.8 + ny * 0.2) * 360 + t * 30, saturation: 1, value: 1))
            intensity = 1

        case .scrolling, .flowing:
            let phase = along(nx, ny) - t * 0.25
            color = settings.multicolor || settings.mode == .flowing
                ? LEDColor(hsv: HSV(hue: phase * 360, saturation: 1, value: 1))
                : base
            intensity = settings.multicolor || settings.mode == .flowing
                ? 1
                : 0.15 + 0.85 * (0.5 + 0.5 * sin(phase * 2 * .pi * 1.5))

        case .rolling, .tilt:
            let phase = (along(nx, ny) + (settings.mode == .tilt ? ny * 0.5 : 0)) - t * 0.3
            color = palette(phase)
            intensity = 0.2 + 0.8 * pow(0.5 + 0.5 * sin(phase * 2 * .pi), 2)

        case .rotating:
            let angle = atan2(ny - 0.5, (nx - 0.5) * (boardWidth / boardHeight))
            let phase = angle / (2 * .pi) + t * 0.2
            color = palette(phase)
            intensity = settings.multicolor ? 1 : 0.2 + 0.8 * (0.5 + 0.5 * sin(phase * 4 * .pi))

        case .outward:
            let distance = hypot((nx - 0.5) * (boardWidth / boardHeight), ny - 0.5)
            let phase = distance - t * 0.25
            color = palette(phase)
            intensity = 0.15 + 0.85 * pow(0.5 + 0.5 * sin(phase * 2 * .pi * 2), 2)

        case .pulsating:
            color = palette(seed)
            intensity = 0.2 + 0.8 * pow(0.5 + 0.5 * sin(t * 3), 3)

        case .glittering:
            let flicker = 0.5 + 0.5 * sin(t * 6 + seed * 97)
            color = palette(seed)
            intensity = pow(flicker, 6)

        case .falling:
            let column = (seed * 13).rounded(.down)
            let drop = (t * 0.6 + column * 0.37).truncatingRemainder(dividingBy: 1.4)
            let distance = drop - along(ny, nx)
            color = palette(column / 13)
            intensity = distance >= 0 && distance < 0.35 ? 1 - distance / 0.35 : 0

        case .shuttle:
            let head = 0.5 + 0.5 * sin(t * 1.2)
            let distance = abs(along(nx, ny) - head)
            color = palette(head)
            intensity = max(0, 1 - distance * 5)

        case .singleOn:
            color = palette(seed)
            intensity = reactive(pressAge)

        case .singleOff:
            color = palette(seed)
            intensity = 1 - reactive(pressAge)

        case .ripples, .explode, .launch:
            // A ring (ripple), filled disc (explode) or upward streak (launch) grows from each press.
            var strongest = reactive(pressAge)
            for press in presses where press.age < Self.reactiveDecay * 1.5 {
                let dx = x - press.x
                let dy = y - press.y
                let radius = press.age * (4 + settings.speedFraction * 10)
                let fade = 1 - press.age / (Self.reactiveDecay * 1.5)
                let value: Double = switch settings.mode {
                case .ripples: max(0, 1 - abs(hypot(dx, dy) - radius) / 0.8) * fade
                case .explode: (hypot(dx, dy) <= radius ? 1 : 0) * fade * 0.8
                default: (abs(dx) < 0.6 && dy <= 0 && -dy <= radius ? 1 : 0) * fade
                }
                strongest = max(strongest, value)
            }
            color = palette(seed)
            intensity = strongest
        }

        return color.scaled(by: min(max(intensity, 0), 1) * level)
    }
}
