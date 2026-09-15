import Foundation

/// An 8-bit-per-channel sRGB color, which is what the keyboard firmware consumes.
public struct LEDColor: Hashable, Codable, Sendable {
    public var red: UInt8
    public var green: UInt8
    public var blue: UInt8

    public init(red: UInt8, green: UInt8, blue: UInt8) {
        self.red = red
        self.green = green
        self.blue = blue
    }

    /// `0xRRGGBB`
    public init(rgb: UInt32) {
        self.init(
            red: UInt8((rgb >> 16) & 0xFF),
            green: UInt8((rgb >> 8) & 0xFF),
            blue: UInt8(rgb & 0xFF)
        )
    }

    /// Accepts `#RRGGBB`, `RRGGBB`, `#RGB` and `RGB` (case-insensitive).
    public init?(hex: String) {
        var text = hex.trimmingCharacters(in: .whitespacesAndNewlines)
        if text.hasPrefix("#") { text.removeFirst() }
        if text.count == 3 {
            text = text.map { "\($0)\($0)" }.joined()
        }
        guard text.count == 6, let value = UInt32(text, radix: 16) else { return nil }
        self.init(rgb: value)
    }

    public var rgb: UInt32 {
        UInt32(red) << 16 | UInt32(green) << 8 | UInt32(blue)
    }

    public var hexString: String {
        String(format: "#%02X%02X%02X", red, green, blue)
    }

    /// Channels as 0...1 doubles.
    public var components: (red: Double, green: Double, blue: Double) {
        (Double(red) / 255, Double(green) / 255, Double(blue) / 255)
    }

    /// Channels in 0...1, clamped.
    public init(normalizedRed red: Double, green: Double, blue: Double) {
        func channel(_ value: Double) -> UInt8 {
            UInt8((min(max(value, 0), 1) * 255).rounded())
        }
        self.init(red: channel(red), green: channel(green), blue: channel(blue))
    }

    /// Relative luminance (WCAG), used to pick legible legend colors.
    public var luminance: Double {
        func linear(_ c: Double) -> Double {
            c <= 0.03928 ? c / 12.92 : pow((c + 0.055) / 1.055, 2.4)
        }
        let c = components
        return 0.2126 * linear(c.red) + 0.7152 * linear(c.green) + 0.0722 * linear(c.blue)
    }

    public func scaled(by factor: Double) -> LEDColor {
        let c = components
        return LEDColor(normalizedRed: c.red * factor, green: c.green * factor, blue: c.blue * factor)
    }

    public func mixed(with other: LEDColor, amount: Double) -> LEDColor {
        let t = min(max(amount, 0), 1)
        let a = components
        let b = other.components
        return LEDColor(
            normalizedRed: a.red + (b.red - a.red) * t,
            green: a.green + (b.green - a.green) * t,
            blue: a.blue + (b.blue - a.blue) * t
        )
    }

    public static let black = LEDColor(rgb: 0x000000)
    public static let white = LEDColor(rgb: 0xFFFFFF)
}

// MARK: - HSV

public struct HSV: Hashable, Sendable {
    /// 0..<360
    public var hue: Double
    /// 0...1
    public var saturation: Double
    /// 0...1
    public var value: Double

    public init(hue: Double, saturation: Double, value: Double) {
        self.hue = hue
        self.saturation = saturation
        self.value = value
    }
}

extension LEDColor {
    public init(hsv: HSV) {
        let h = (hsv.hue.truncatingRemainder(dividingBy: 360) + 360).truncatingRemainder(dividingBy: 360)
        let s = min(max(hsv.saturation, 0), 1)
        let v = min(max(hsv.value, 0), 1)
        let c = v * s
        let x = c * (1 - abs((h / 60).truncatingRemainder(dividingBy: 2) - 1))
        let m = v - c
        let (r, g, b): (Double, Double, Double)
        switch h {
        case 0..<60: (r, g, b) = (c, x, 0)
        case 60..<120: (r, g, b) = (x, c, 0)
        case 120..<180: (r, g, b) = (0, c, x)
        case 180..<240: (r, g, b) = (0, x, c)
        case 240..<300: (r, g, b) = (x, 0, c)
        default: (r, g, b) = (c, 0, x)
        }
        self.init(normalizedRed: r + m, green: g + m, blue: b + m)
    }

    public var hsv: HSV {
        let (r, g, b) = components
        let maxC = max(r, g, b)
        let minC = min(r, g, b)
        let delta = maxC - minC
        var hue: Double = 0
        if delta > 0 {
            switch maxC {
            case r: hue = 60 * ((g - b) / delta).truncatingRemainder(dividingBy: 6)
            case g: hue = 60 * ((b - r) / delta + 2)
            default: hue = 60 * ((r - g) / delta + 4)
            }
        }
        if hue < 0 { hue += 360 }
        return HSV(hue: hue, saturation: maxC == 0 ? 0 : delta / maxC, value: maxC)
    }
}
