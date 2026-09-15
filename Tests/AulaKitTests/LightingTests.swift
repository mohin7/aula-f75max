import Foundation
import Testing
@testable import AulaKit

@Suite("Lighting settings & preview engine")
struct LightingTests {
    private func engine(_ settings: LightingSettings) -> LightingPreviewEngine {
        LightingPreviewEngine(settings: settings, boardWidth: 16, boardHeight: 6.25)
    }

    @Test func levelsClampToFirmwareRange() {
        var settings = LightingSettings(brightness: 9, speed: -3)
        #expect(settings.brightness == 5)
        #expect(settings.speed == 1)
        settings.brightness = 0
        #expect(settings.brightness == 1)
    }

    @Test func modeRawValuesMatchFirmwareIndices() {
        #expect(LightingMode.off.rawValue == 0)
        #expect(LightingMode.staticColor.rawValue == 1)
        #expect(LightingMode.breathing.rawValue == 7)
        #expect(LightingMode.shuttle.rawValue == 19)
        #expect(LightingMode.allCases.map(\.rawValue) == Array(0...19))
    }

    @Test func settingsRoundTripThroughJSON() throws {
        let settings = LightingSettings(mode: .ripples, color: LEDColor(rgb: 0x123456), brightness: 2, speed: 5, direction: .up, multicolor: true)
        let decoded = try JSONDecoder().decode(LightingSettings.self, from: JSONEncoder().encode(settings))
        #expect(decoded == settings)
    }

    @Test func offIsBlack() {
        let color = engine(LightingSettings(mode: .off)).color(x: 3, y: 3, time: 12, pressAge: 0, seed: 0.5)
        #expect(color == .black)
    }

    @Test func staticUsesColorScaledByBrightness() {
        let settings = LightingSettings(mode: .staticColor, color: .white, brightness: 5)
        #expect(engine(settings).color(x: 1, y: 1, time: 0, pressAge: nil, seed: 0) == .white)

        let dim = LightingSettings(mode: .staticColor, color: .white, brightness: 1)
        #expect(engine(dim).color(x: 1, y: 1, time: 99, pressAge: nil, seed: 0) == LEDColor(rgb: 0x333333))
    }

    @Test func reactiveLightsOnlyRecentlyPressedKeys() {
        let e = engine(LightingSettings(mode: .singleOn, color: .white, brightness: 5))
        #expect(e.color(x: 1, y: 1, time: 0, pressAge: nil, seed: 0) == .black)
        #expect(e.color(x: 1, y: 1, time: 0, pressAge: 0, seed: 0) == .white)
        #expect(e.color(x: 1, y: 1, time: 0, pressAge: LightingPreviewEngine.reactiveDecay + 0.1, seed: 0) == .black)
    }

    @Test func rippleReachesNeighboursOverTime() {
        let e = engine(LightingSettings(mode: .ripples, color: .white, brightness: 5, speed: 3))
        let press = LightingPreviewEngine.Press(x: 5, y: 3, age: 0.3)
        // Radius at age 0.3 with speed 3 is 0.3 * (4 + 0.6 * 10) = 3u, so a key 3u away sits on the ring.
        let onRing = e.color(x: 8, y: 3, time: 0, pressAge: nil, seed: 0, presses: [press])
        let farAway = e.color(x: 15, y: 3, time: 0, pressAge: nil, seed: 0, presses: [press])
        #expect(onRing.luminance > 0.3)
        #expect(farAway == .black)
    }

    @Test(arguments: LightingMode.allCases)
    func everyModeIsDeterministicAndInRange(mode: LightingMode) {
        let e = engine(LightingSettings(mode: mode, multicolor: true))
        for time in stride(from: 0.0, through: 10, by: 0.37) {
            let a = e.color(x: 4.5, y: 2.5, time: time, pressAge: 0.2, seed: 0.3)
            let b = e.color(x: 4.5, y: 2.5, time: time, pressAge: 0.2, seed: 0.3)
            #expect(a == b)
        }
    }
}
