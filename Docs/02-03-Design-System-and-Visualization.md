# Phases 2 and 3: Design system and keyboard visualization

## Phase 2: `AulaDesignSystem`

### Architecture
- A standalone SwiftPM target with **no dependency on AulaKit**. Components take plain values (strings, colors, bindings), so they can be reused for future keyboards, marketplace UIs or a separate app.
- **Tokens** (`Tokens/`) are the only place raw numbers and colors live. Components use them. Feature code uses components first and tokens second.
- **Theming:** semantic colors resolve dynamically through `NSColor(name:dynamicProvider:)` for light, dark and high contrast. The brand accent is injected through the `\.studioAccent` environment key. The root view sets it from the keyboard's lighting color.
- **Motion:** every animation goes through `Motion.animation(_:reduceMotion:)`, so Reduce Motion is honored in one place.
- **Accessibility built in:** sliders, dials and hue strips implement `accessibilityAdjustableAction`. Cards merge into label/value pairs. Toasts use `.updatesFrequently`.

### Adding a component
1. Put it in `Components/`, make it `public`, and only take values or bindings.
2. Use tokens only (spacing, radius, typography, palette).
3. Give it an accessibility label/value, plus an adjustable action for anything that changes a value.
4. If it has logic (queues, validation), add a test in `AulaDesignSystemTests`.

### Testing strategy
- **Unit:** token invariants (4-pt grid, spec radii), `ToastCenter` queue behavior, hex validation.
- **Visual:** screenshots of the running app in light, dark and demo mode during review. Snapshot tests are planned for Phase 10 once Xcode is available (they need `ImageRenderer` plus the Xcode test host).

## Phase 3: Keyboard visualization

### Data model (AulaKit, fully tested)
- `KeyboardLayout`: geometry in key units, `KeyDefinition` (stable `id`, legend, rect, HID usage, row), knob, display, and the Mac-mode usage remap. It's `Codable`, so future layouts (F87, F98, F108) can ship as JSON.
- `KeyboardLayout.f75Max`: 81 keys, 16u × 6.25u, knob and 128×128 display in the function row.
- `LightingPreviewEngine`: a pure function of (settings, key position, time, press age, recent presses) → `LEDColor`. It approximates all 20 firmware effects, including radiating ripple, explode and launch.

### Rendering (`AULAStudio/Components/Keyboard`)
| Layer | Tech | Redraws on |
|---|---|---|
| Case and plate | SwiftUI shapes | resize |
| LED light | `LEDLightView`: `CADisplayLink` → 96×38 bitmap → `CALayer` upscaled with linear filtering | every frame while animated. Stops when static and skips frames when occluded. |
| Keycaps | `Canvas` (skirt + face, translucent so LEDs tint them) | press, hover, selection |
| Legends | `Text` | press, legend mode |
| TFT display | SwiftUI (`TimelineView(.everyMinute)`) | minute, status changes |
| Knob | `KnobFace` with spring rotation | knob events |
| Interaction | Transparent hit layer | — |

The LED layer bypasses SwiftUI on purpose. The first version (`TimelineView` + `Canvas`) cost 26–35% CPU because every tick re-ran the window's layout pass. The display-link layer costs ~7–11% and uses about a third of the memory.

### Interaction
- Hover highlight. Click selects, clicking again deselects, ⌘/⇧-click toggles, drag paints a multi-selection (the basis for Phase 5's paint tool).
- Arrow keys move to the nearest key in that direction, and Esc clears.
- A single selected key opens the floating `KeyInspector`.
- Live input: `KeyEventMonitor` (IOKit, AULA device only, never seized) → pressed caps sink, reactive effects fire, the knob rotates on volume events and depresses on mute.
- Caps Lock comes from `CGEventSource.flagsState` (no permission needed). Win/Mac legends are chosen in Settings.

### Key Tester (layout verification)
Dashboard → **Key Tester** logs every event with its HID usage and the key it mapped to, and tracks coverage. If a key shows **not in layout** or lights the wrong position, the layout table needs fixing. That makes it the loop for confirming the right-hand column and the Mac-mode modifiers on real hardware.

### Testing strategy
- **Layout geometry:** unique IDs and usages, no overlaps (keys, knob, display), rows fill 16u exactly, hit-testing, Mac-mode remap, JSON round-trip.
- **Lighting engine:** determinism for all modes, off → black, brightness scaling, reactive decay, ripple propagation radius.
- **Endpoint classification:** a fixture copied from the real BLE IORegistry entry, plus wired, dongle, Apple-VID collision and link ordering.
- **Hardware:** `make endpoints`, `make keys`, and Key Tester coverage.
- **Performance:** release build, `top` and `footprint` in static and animated modes (numbers in `Roadmap.md`).
