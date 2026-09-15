import Foundation

/// A HID usage: a (page, id) pair such as Keyboard/0x04 ("A") or Consumer/0xE9 ("Volume Up").
public struct HIDUsage: Hashable, Codable, Sendable, CustomStringConvertible {
    public var page: UInt32
    public var id: UInt32

    public init(page: UInt32, id: UInt32) {
        self.page = page
        self.id = id
    }

    public static func keyboard(_ id: UInt32) -> HIDUsage { HIDUsage(page: Page.keyboard, id: id) }
    public static func consumer(_ id: UInt32) -> HIDUsage { HIDUsage(page: Page.consumer, id: id) }

    public enum Page {
        public static let genericDesktop: UInt32 = 0x01
        public static let keyboard: UInt32 = 0x07
        public static let led: UInt32 = 0x08
        public static let consumer: UInt32 = 0x0C
    }

    public var description: String {
        String(format: "0x%02X:0x%02X", page, id)
    }

    /// Readable name for diagnostics.
    public var name: String {
        switch page {
        case Page.keyboard: HIDUsage.keyboardNames[id] ?? String(format: "Key 0x%02X", id)
        case Page.consumer: HIDUsage.consumerNames[id] ?? String(format: "Consumer 0x%02X", id)
        default: description
        }
    }

    public var isModifier: Bool { page == Page.keyboard && (0xE0...0xE7).contains(id) }

    // Keyboard/Keypad page (0x07), HID Usage Tables 1.5 §10.
    static let keyboardNames: [UInt32: String] = {
        var names: [UInt32: String] = [:]
        for (offset, letter) in "ABCDEFGHIJKLMNOPQRSTUVWXYZ".enumerated() {
            names[0x04 + UInt32(offset)] = String(letter)
        }
        for (offset, digit) in "1234567890".enumerated() {
            names[0x1E + UInt32(offset)] = String(digit)
        }
        for n in 1...12 {
            names[0x39 + UInt32(n)] = "F\(n)"
        }
        let rest: [UInt32: String] = [
            0x28: "Return", 0x29: "Escape", 0x2A: "Backspace", 0x2B: "Tab", 0x2C: "Space",
            0x2D: "-", 0x2E: "=", 0x2F: "[", 0x30: "]", 0x31: "\\", 0x33: ";", 0x34: "'",
            0x35: "`", 0x36: ",", 0x37: ".", 0x38: "/", 0x39: "Caps Lock",
            0x46: "Print Screen", 0x47: "Scroll Lock", 0x48: "Pause",
            0x49: "Insert", 0x4A: "Home", 0x4B: "Page Up", 0x4C: "Delete", 0x4D: "End",
            0x4E: "Page Down", 0x4F: "Right Arrow", 0x50: "Left Arrow", 0x51: "Down Arrow",
            0x52: "Up Arrow", 0x64: "ISO \\", 0x65: "Application",
            0xE0: "Left Control", 0xE1: "Left Shift", 0xE2: "Left Option/Alt", 0xE3: "Left Command/Win",
            0xE4: "Right Control", 0xE5: "Right Shift", 0xE6: "Right Option/Alt", 0xE7: "Right Command/Win",
        ]
        names.merge(rest) { $1 }
        return names
    }()

    // Consumer page (0x0C), the knob's rotate and press actions show up here.
    static let consumerNames: [UInt32: String] = [
        0x6F: "Brightness Up", 0x70: "Brightness Down",
        0xB5: "Next Track", 0xB6: "Previous Track", 0xB7: "Stop", 0xB8: "Eject",
        0xCD: "Play/Pause", 0xE2: "Mute", 0xE9: "Volume Up", 0xEA: "Volume Down",
    ]
}
