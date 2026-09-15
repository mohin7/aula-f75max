/**
 * AULA F75 Max layout, ported from the app (`Sources/AulaKit/Keymap/Layouts/F75MaxLayout.swift`).
 * Units are key units ("u"): a standard letter key is 1u wide.
 */
export interface KeyDef {
  id: string
  label: string
  /** Legend shown on Mac, when it differs (⌘, ⌥ …). */
  mac?: string
  shifted?: string
  x: number
  y: number
  w: number
  row: number
  /** HID usage name, as reported by the app's Key Tester. */
  usage: string
}

const ROW_GAP = 0.25

function row(index: number, y: number, keys: Array<[string, string, number?, Partial<KeyDef>?]>): KeyDef[] {
  let cursor = 0
  return keys.map(([id, label, w = 1, extra = {}]) => {
    const key: KeyDef = { id, label, x: cursor, y, w, row: index, usage: extra.usage ?? label, ...extra }
    cursor += w
    return key
  })
}

const letters = (chars: string): Array<[string, string]> => [...chars].map((c) => [c.toLowerCase(), c])

export const keys: KeyDef[] = [
  ...row(0, 0, [
    ['esc', 'Esc', 1, { usage: 'Escape' }],
    ...Array.from({ length: 12 }, (_, i): [string, string] => [`f${i + 1}`, `F${i + 1}`]),
  ]),
  ...row(1, 1 + ROW_GAP, [
    ['grave', '`', 1, { shifted: '~' }],
    ['num1', '1', 1, { shifted: '!' }], ['num2', '2', 1, { shifted: '@' }], ['num3', '3', 1, { shifted: '#' }],
    ['num4', '4', 1, { shifted: '$' }], ['num5', '5', 1, { shifted: '%' }], ['num6', '6', 1, { shifted: '^' }],
    ['num7', '7', 1, { shifted: '&' }], ['num8', '8', 1, { shifted: '*' }], ['num9', '9', 1, { shifted: '(' }],
    ['num0', '0', 1, { shifted: ')' }],
    ['minus', '-', 1, { shifted: '_' }], ['equal', '=', 1, { shifted: '+' }],
    ['backspace', 'Backspace', 2, { mac: '⌫' }],
    ['delete', 'Del', 1, { usage: 'Delete' }],
  ]),
  ...row(2, 2 + ROW_GAP, [
    ['tab', 'Tab', 1.5, { mac: '⇥' }],
    ...letters('QWERTYUIOP'),
    ['lbracket', '[', 1, { shifted: '{' }], ['rbracket', ']', 1, { shifted: '}' }],
    ['backslash', '\\', 1.5, { shifted: '|' }],
    ['pageup', 'PgUp', 1, { usage: 'Page Up' }],
  ]),
  ...row(3, 3 + ROW_GAP, [
    ['capslock', 'Caps', 1.75, { mac: '⇪', usage: 'Caps Lock' }],
    ...letters('ASDFGHJKL'),
    ['semicolon', ';', 1, { shifted: ':' }], ['quote', "'", 1, { shifted: '"' }],
    ['enter', 'Enter', 2.25, { mac: '↩', usage: 'Return' }],
    ['pagedown', 'PgDn', 1, { usage: 'Page Down' }],
  ]),
  ...row(4, 4 + ROW_GAP, [
    ['lshift', 'Shift', 2.25, { mac: '⇧', usage: 'Left Shift' }],
    ...letters('ZXCVBNM'),
    ['comma', ',', 1, { shifted: '<' }], ['period', '.', 1, { shifted: '>' }], ['slash', '/', 1, { shifted: '?' }],
    ['rshift', 'Shift', 1.75, { mac: '⇧', usage: 'Right Shift' }],
    ['up', '↑', 1, { usage: 'Up Arrow' }],
    ['end', 'End', 1],
  ]),
  ...row(5, 5 + ROW_GAP, [
    ['lctrl', 'Ctrl', 1.25, { mac: '⌃', usage: 'Left Control' }],
    ['lgui', 'Win', 1.25, { mac: '⌥', usage: 'Left Option' }],
    ['lalt', 'Alt', 1.25, { mac: '⌘', usage: 'Left Command' }],
    ['space', '', 6.25, { usage: 'Space' }],
    ['ralt', 'Alt', 1, { mac: '⌘', usage: 'Right Command' }],
    ['fn', 'Fn', 1, { usage: 'Fn (handled by firmware)' }],
    ['rctrl', 'Ctrl', 1, { mac: '⌃', usage: 'Right Control' }],
    ['left', '←', 1, { usage: 'Left Arrow' }],
    ['down', '↓', 1, { usage: 'Down Arrow' }],
    ['right', '→', 1, { usage: 'Right Arrow' }],
  ]),
]

export const layout = {
  width: 16,
  height: 6 + ROW_GAP,
  display: { x: 13.2, y: 0, w: 1.3, h: 1 },
  knob: { x: 14.75, y: -0.05, size: 1.1 },
} as const
