import Foundation
import Testing
@testable import AulaKit

@Suite("LEDColor")
struct LEDColorTests {
    @Test(arguments: ["#6E7BFF", "6e7bff", " #6E7BFF\n"])
    func parsesSixDigitHex(input: String) {
        #expect(LEDColor(hex: input) == LEDColor(red: 0x6E, green: 0x7B, blue: 0xFF))
    }

    @Test func expandsShortHex() {
        #expect(LEDColor(hex: "#F0A") == LEDColor(rgb: 0xFF00AA))
    }

    @Test(arguments: ["", "#12345", "GGGGGG", "#1234567"])
    func rejectsInvalidHex(input: String) {
        #expect(LEDColor(hex: input) == nil)
    }

    @Test func formatsHex() {
        #expect(LEDColor(rgb: 0x0A0B0C).hexString == "#0A0B0C")
    }

    @Test func hsvPrimaries() {
        #expect(LEDColor(hsv: HSV(hue: 0, saturation: 1, value: 1)) == LEDColor(rgb: 0xFF0000))
        #expect(LEDColor(hsv: HSV(hue: 120, saturation: 1, value: 1)) == LEDColor(rgb: 0x00FF00))
        #expect(LEDColor(hsv: HSV(hue: 240, saturation: 1, value: 1)) == LEDColor(rgb: 0x0000FF))
        #expect(LEDColor(hsv: HSV(hue: 360, saturation: 1, value: 1)) == LEDColor(rgb: 0xFF0000))
        #expect(LEDColor(hsv: HSV(hue: -120, saturation: 1, value: 1)) == LEDColor(rgb: 0x0000FF))
    }

    @Test func hsvRoundTripIsLossless() {
        var generator = SystemRandomNumberGenerator()
        for _ in 0..<500 {
            let color = LEDColor(rgb: UInt32.random(in: 0...0xFFFFFF, using: &generator))
            #expect(LEDColor(hsv: color.hsv) == color, "\(color.hexString)")
        }
    }

    @Test func mixingAndScaling() {
        #expect(LEDColor.black.mixed(with: .white, amount: 0.5) == LEDColor(rgb: 0x808080))
        #expect(LEDColor.white.scaled(by: 0) == .black)
        #expect(LEDColor.white.scaled(by: 2) == .white)
    }

    @Test func luminanceBounds() {
        #expect(LEDColor.black.luminance == 0)
        #expect(abs(LEDColor.white.luminance - 1) < 0.0001)
    }
}
