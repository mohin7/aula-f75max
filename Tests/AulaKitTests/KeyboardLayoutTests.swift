import Foundation
import Testing
@testable import AulaKit

@Suite("F75 Max layout")
struct KeyboardLayoutTests {
    let layout = KeyboardLayout.f75Max

    @Test func has81Keys() {
        #expect(layout.keys.count == 81)
    }

    @Test func keyIDsAreUnique() {
        #expect(Set(layout.keys.map(\.id)).count == layout.keys.count)
    }

    @Test func usagesAreUniqueExceptFirmwareKeys() {
        let usages = layout.keys.compactMap(\.usage)
        #expect(Set(usages).count == usages.count)
        #expect(layout.keys.filter { $0.usage == nil }.map(\.id) == ["fn"])
    }

    @Test func noKeysOverlap() {
        for (i, a) in layout.keys.enumerated() {
            for b in layout.keys[(i + 1)...] {
                #expect(!a.rect.intersects(b.rect), "\(a.id) overlaps \(b.id)")
            }
        }
    }

    @Test func knobAndDisplayDontOverlapKeys() throws {
        let knob = try #require(layout.knob)
        let display = try #require(layout.display)
        #expect(!knob.rect.intersects(display.rect))
        for key in layout.keys {
            #expect(!key.rect.intersects(knob.rect), "\(key.id) overlaps knob")
            #expect(!key.rect.intersects(display.rect), "\(key.id) overlaps display")
        }
    }

    @Test(arguments: 1...5)
    func alphanumericRowsFillThePlateWidth(row: Int) {
        let keys = layout.keys.filter { $0.row == row }
        let maxX = keys.map(\.rect.maxX).max() ?? 0
        #expect(abs(maxX - layout.width) < 0.001, "row \(row) ends at \(maxX)")
        let total = keys.map(\.rect.width).reduce(0, +)
        #expect(abs(total - layout.width) < 0.001, "row \(row) has gaps: \(total)u")
    }

    @Test func everythingFitsInsideThePlate() {
        for key in layout.keys {
            #expect(key.rect.x >= 0 && key.rect.maxX <= layout.width + 0.001)
            #expect(key.rect.y >= 0 && key.rect.maxY <= layout.height + 0.001)
        }
    }

    @Test func hitTesting() {
        #expect(layout.key(at: 0.5, 0.5)?.id == "esc")
        #expect(layout.key(at: 7, 5.75)?.id == "space")
        #expect(layout.key(at: 13.5, 0.5) == nil) // display area
    }

    @Test func macModeRemapsModifierPositions() {
        // In Mac mode, position 2 sends Left Option (0xE2) and should resolve to that position ("lgui").
        #expect(layout.keys(for: .keyboard(0xE2), mode: .mac).map(\.id) == ["lgui"])
        #expect(layout.keys(for: .keyboard(0xE3), mode: .mac).map(\.id) == ["lalt"])
        #expect(layout.keys(for: .keyboard(0xE2), mode: .windows).map(\.id) == ["lalt"])
        #expect(layout.keys(for: .keyboard(0x04), mode: .mac).map(\.id) == ["a"])
    }

    @Test func legendModeSelection() throws {
        let lgui = try #require(layout.key(id: "lgui"))
        #expect(lgui.legend.text(for: .mac) == "⌥")
        #expect(lgui.legend.text(for: .windows) == "Win")
    }

    @Test func layoutRoundTripsThroughJSON() throws {
        let data = try JSONEncoder().encode(layout)
        let decoded = try JSONDecoder().decode(KeyboardLayout.self, from: data)
        #expect(decoded == layout)
    }
}
