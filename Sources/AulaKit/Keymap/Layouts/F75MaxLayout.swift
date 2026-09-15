import Foundation

extension KeyboardLayout {
    /// AULA F75 Max, ANSI: 81 keys, a knob and a 128×128 TFT display.
    ///
    /// The right-hand column (Del / PgUp / PgDn / End) comes from product photos.
    /// Use Dashboard → Key Tester to check it against real hardware: if pressing a
    /// key lights up the wrong position, fix the entry here.
    public static let f75Max: KeyboardLayout = {
        var builder = RowBuilder()

        // Row 0: function row. The display and knob sit to the right of F12.
        builder.row(0, y: 0) { r in
            r.key("esc", "Esc", 0x29)
            for n in 1...12 {
                r.key("f\(n)", "F\(n)", 0x39 + UInt32(n))
            }
        }

        let rowGap = 0.25
        // Row 1: number row.
        builder.row(1, y: 1 + rowGap) { r in
            r.key("grave", "`", 0x35, shifted: "~")
            let shifted = ["!", "@", "#", "$", "%", "^", "&", "*", "(", ")"]
            for (i, digit) in ["1", "2", "3", "4", "5", "6", "7", "8", "9", "0"].enumerated() {
                r.key("num\(digit)", digit, digit == "0" ? 0x27 : 0x1E + UInt32(i), shifted: shifted[i])
            }
            r.key("minus", "-", 0x2D, shifted: "_")
            r.key("equal", "=", 0x2E, shifted: "+")
            r.key("backspace", "Backspace", 0x2A, width: 2, mac: "⌫")
            r.key("delete", "Del", 0x4C)
        }

        builder.row(2, y: 2 + rowGap) { r in
            r.key("tab", "Tab", 0x2B, width: 1.5, mac: "⇥")
            r.letters("QWERTYUIOP")
            r.key("lbracket", "[", 0x2F, shifted: "{")
            r.key("rbracket", "]", 0x30, shifted: "}")
            r.key("backslash", "\\", 0x31, width: 1.5, shifted: "|")
            r.key("pageup", "PgUp", 0x4B)
        }

        builder.row(3, y: 3 + rowGap) { r in
            r.key("capslock", "Caps", 0x39, width: 1.75, mac: "⇪")
            r.letters("ASDFGHJKL")
            r.key("semicolon", ";", 0x33, shifted: ":")
            r.key("quote", "'", 0x34, shifted: "\"")
            r.key("enter", "Enter", 0x28, width: 2.25, mac: "↩")
            r.key("pagedown", "PgDn", 0x4E)
        }

        builder.row(4, y: 4 + rowGap) { r in
            r.key("lshift", "Shift", 0xE1, width: 2.25, mac: "⇧")
            r.letters("ZXCVBNM")
            r.key("comma", ",", 0x36, shifted: "<")
            r.key("period", ".", 0x37, shifted: ">")
            r.key("slash", "/", 0x38, shifted: "?")
            r.key("rshift", "Shift", 0xE5, width: 1.75, mac: "⇧")
            r.key("up", "↑", 0x52)
            r.key("end", "End", 0x4D)
        }

        builder.row(5, y: 5 + rowGap) { r in
            r.key("lctrl", "Ctrl", 0xE0, width: 1.25, mac: "⌃")
            r.key("lgui", "Win", 0xE3, width: 1.25, mac: "⌥", windows: "Win")
            r.key("lalt", "Alt", 0xE2, width: 1.25, mac: "⌘", windows: "Alt")
            r.key("space", "", 0x2C, width: 6.25)
            r.key("ralt", "Alt", 0xE6, mac: "⌘", windows: "Alt")
            r.key("fn", "Fn", nil)
            r.key("rctrl", "Ctrl", 0xE4, mac: "⌃")
            r.key("left", "←", 0x50)
            r.key("down", "↓", 0x51)
            r.key("right", "→", 0x4F)
        }

        return KeyboardLayout(
            name: "AULA F75 Max",
            keys: builder.keys,
            knob: KnobDefinition(
                rect: KeyRect(x: 14.75, y: -0.05, width: 1.1, height: 1.1),
                rotateClockwise: .consumer(0xE9),
                rotateCounterClockwise: .consumer(0xEA),
                press: .consumer(0xE2)
            ),
            display: DisplayDefinition(
                rect: KeyRect(x: 13.2, y: 0, width: 1.3, height: 1),
                pixelWidth: 128,
                pixelHeight: 128
            ),
            width: 16,
            height: 6 + rowGap,
            // Mac mode: position 2 sends Option, position 3 sends Command.
            macModeUsageRemap: [0xE2: 0xE3, 0xE3: 0xE2, 0xE7: 0xE6]
        )
    }()
}

// MARK: - Builder

private struct RowBuilder {
    var keys: [KeyDefinition] = []

    mutating func row(_ index: Int, y: Double, _ build: (inout Row) -> Void) {
        var row = Row(index: index, y: y)
        build(&row)
        keys.append(contentsOf: row.keys)
    }

    struct Row {
        let index: Int
        let y: Double
        var cursor: Double = 0
        var keys: [KeyDefinition] = []

        mutating func key(
            _ id: String,
            _ label: String,
            _ usage: UInt32?,
            width: Double = 1,
            shifted: String? = nil,
            mac: String? = nil,
            windows: String? = nil
        ) {
            keys.append(KeyDefinition(
                id: id,
                legend: KeyLegend(label, secondary: shifted, mac: mac, windows: windows),
                rect: KeyRect(x: cursor, y: y, width: width, height: 1),
                usage: usage.map(HIDUsage.keyboard),
                row: index
            ))
            cursor += width
        }

        mutating func letters(_ letters: String) {
            for letter in letters {
                let offset = UInt32(letter.asciiValue! - Character("A").asciiValue!)
                key(letter.lowercased(), String(letter), 0x04 + offset)
            }
        }
    }
}
