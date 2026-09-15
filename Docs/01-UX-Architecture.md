# Phase 1: UX Architecture

This covers information architecture, user flows, the component inventory, design tokens and wireframes.
The running app (Phases 2–3) implements these screens. Where the app and this document disagree, the app wins, and this document gets updated.

---

## 1. Product principles

1. **The keyboard is the interface.** Every screen centers on the live keyboard render. Changing a setting shows up there instantly.
2. **Honest capabilities.** The F75 Max can do different things on each link (USB-C, 2.4G, Bluetooth). The UI never offers a control that won't reach the hardware without saying so inline.
3. **Instant, then persistent.** Preview updates right away. Writes to the device are debounced and confirmed. State is cached, so reconnecting never shows a loading screen.
4. **Keyboard-first.** ⌘K reaches everything, ⌘1–⌘8 switch sections, arrow keys move the key selection, and Esc dismisses.
5. **Quiet chrome, loud content.** Surfaces stay neutral. The only saturated color is the accent, which follows the keyboard's RGB.

## 2. Capability matrix (drives the UI)

| Capability | USB-C | 2.4G receiver | Bluetooth | Source |
|---|---|---|---|---|
| Live key and knob events | ✅ | ✅ | ✅ (verified) | Standard HID |
| Firmware lighting modes | ✅ | ✅ | ❌ | Community protocol |
| Display image/GIF upload | ✅ | ❌ | ❌ | Community protocol |
| Clock sync | ✅ | ❌ | ❌ | Community protocol |
| Battery % | ❓ | ✅ | ❌ (not exposed, verified) | Community protocol |
| Response level, sleep, Game Mode | ❓ | ✅ | ❌ | Community protocol |
| On-board keymap | ❓ needs capture | ❓ | ❌ | Unknown |
| Per-key RGB | ❓ needs capture | ❓ | ❌ | Unknown |
| Firmware update | ⛔ blocked | ⛔ | ⛔ | No vendor images |
| Mac-side remaps and macros | ✅ | ✅ | ✅ | Runs on the Mac |

In code, `ConnectionKind.capabilities` holds this matrix. `ConnectedKeyboard.capabilities` narrows it to the endpoints actually present.

## 3. Information architecture

```
AULA Studio
├── Dashboard ........... live keyboard, status cards, key inspector, Key Tester
├── Lighting ............ effect grid, color, brightness, speed, direction (per-key editor in Phase 5)
├── Display ............. media library, crop and adjust, widgets, pixel editor (Phase 6)
├── Keymap .............. layers, remap palette, knob actions, conflicts (Phase 7)
├── Macros .............. library, timeline editor, recorder (Phase 7)
├── Profiles ............ list, per-app auto-switch, automations, import/export (Phase 9)
├── Firmware ............ version, update, recovery (Phase 8, blocked)
└── Settings
    ├── Appearance ...... theme, accent follows lighting
    ├── Keyboard ........ Win/Mac legends
    ├── General ......... menu bar icon, Input Monitoring
    └── Developer ....... demo keyboard, HID diagnostics

Global: ⌘K command palette · toasts · menu bar companion · Settings window (⌘,)
```

Navigation uses a **sidebar**, not the top tab bar the brief described. With eight peer sections, a sidebar follows macOS HIG, leaves room for the device footer (link, battery), and scales as marketplace sections arrive.

## 4. Key user flows

### 4.1 First launch → connected

```
Launch ──► Window shows the keyboard (cached layout, no spinner)
   │
   ├─ keyboard found ─► toast "AULA F75Max-1 connected · Bluetooth"
   │                    └─ Bluetooth? ─► warning callout: view-only, switch link to configure
   └─ none ───────────► info callout: "Plug in USB-C, insert receiver, or pair"
   │
   └─ Input Monitoring not granted ─► callout [Allow] ─► system prompt ─► live key preview on
```

### 4.2 Change lighting (Phase 5 complete)

```
Lighting ─► pick effect tile ─► preview animates instantly
        ─► drag brightness ─► preview updates each frame; device write debounced (~80 ms)
        ─► write acked ─► status stays quiet ─ write fails ─► toast "Couldn't reach keyboard" + retry
```

### 4.3 Inspect and remap a key (Phase 7)

```
Click key (or arrow to it) ─► floating inspector slides in
   ├─ Identity: legend, HID usage, tested state
   ├─ Lighting: per-key color and effect
   └─ Action: search palette ─► assign ─► conflict check ─► apply to layer
⌘-click or drag across keys ─► multi-select ─► bulk color or action
```

### 4.4 Verify layout (Key Tester, available now)

```
Dashboard ─► Key Tester ─► press every key ─► coverage bar fills
   └─ an event shows "not in layout", or the wrong key lights ─► fix F75MaxLayout.swift
```

### 4.5 Auto profile switch (Phase 9)

```
Frontmost app changes ─► match rule (bundle ID) ─► apply profile diff (lighting, keymap, knob, macros)
                      ─► subtle toast "Figma profile"
```

## 5. Component inventory

| Component | Module | Status | Notes |
|---|---|---|---|
| `StudioCard` | DesignSystem | ✅ | 18 pt radius, hairline stroke |
| `SectionHeader` | DesignSystem | ✅ | Title, subtitle, trailing accessory |
| `StatCard` | DesignSystem | ✅ | Dashboard tile, numeric content transitions |
| `StatusPill` | DesignSystem | ✅ | Connected/warning/disconnected |
| `Callout` | DesignSystem | ✅ | Capability, permission and warning notices with action |
| `StudioSlider` | DesignSystem | ✅ | Continuous or stepped, VoiceOver adjustable |
| `StudioSegmentedControl` | DesignSystem | ✅ | Sliding indicator (matchedGeometry) |
| `ToggleRow` | DesignSystem | ✅ | |
| `KnobDial` / `KnobFace` | DesignSystem | ✅ | Drag to rotate; face reused by the keyboard |
| `BatteryGauge` | DesignSystem | ✅ | Unknown state is explicit |
| `ColorSwatch`, `HueStrip`, `HexColorField` | DesignSystem | ✅ | Hex validates before commit |
| `FloatingInspector`, `PropertyRow` | DesignSystem | ✅ | 24 pt radius material panel |
| `KeyCapView` | DesignSystem | ✅ | View-based cap for inspectors and palettes |
| `ToastCenter` + `.toastOverlay` | DesignSystem | ✅ | Queue, one at a time |
| Button styles (primary, secondary, icon) | DesignSystem | ✅ | |
| `KeyboardStage` | App | ✅ | Layered renderer, see Phase 3 |
| `LEDLightView` | App | ✅ | Display-link CALayer LED renderer |
| `DisplayScreenPreview` | App | ✅ | 128×128 TFT mock |
| `CommandPalette` | App | ✅ | ⌘K, fuzzy terms, arrow navigation |
| Sidebar + device footer | App | ✅ | |
| Menu bar companion | App | ✅ | Brightness, effect, status |
| Context menu (key) | App | ⏳ Phase 5/7 | Copy/paste lighting, reset key |
| Modal sheet | App | ⏳ Phase 6 | Crop tool |
| Timeline | DesignSystem | ⏳ Phase 5/7 | Shared by RGB timeline and macros |

## 6. Design tokens

Source of truth: `Sources/AulaDesignSystem/Tokens/`.

**Spacing, 4 pt grid:** `xxs 4 · xs 8 · sm 12 · md 16 · lg 20 · xl 24 · xxl 32 · xxxl 48`. Unit tests check the grid.

**Radius:** `xs 6 (keycaps) · sm 10 (controls) · md 14 (rows) · lg 18 (cards) · xl 24 (inspectors, palette) · xxl 32 (keyboard stage)`

**Type (SF Pro, Dynamic Type-aware):**

| Token | Style | Use |
|---|---|---|
| `largeTitle` | 26 semibold | Page titles |
| `title` | 17 semibold (title2) | Card values |
| `headline` | 13 semibold | Card and section titles |
| `body` | 13 regular | Text |
| `label` | 12 medium | Control labels |
| `caption` | 10 regular | Supporting detail |
| `eyebrow` | 10 semibold caps | Group headers |
| `mono` | 12 monospaced | Hex, HID usages |

**Color, semantic and adaptive:** `canvas · surface · surfaceRaised · surfaceSunken · stroke · strokeStrong · textPrimary/Secondary/Tertiary · success · warning · danger · info`. The keyboard stage uses fixed dark materials (`caseTop/Bottom`, `keycapFace/Skirt/Legend`) because the physical keyboard doesn't change with the theme.

**Accent:** follows `LightingSettings.color` when it's vivid enough (S > 0.25, V > 0.35), clamped for legibility. Otherwise it falls back to `#6E7BFF`.

**Motion:** `snappy` (0.22 s, press and hover) · `smooth` (0.36 s, panels) · `gentle` (0.5 s, layout). Every animation goes through `Motion.animation(_:reduceMotion:)`.

**Elevation:** `flat · raised (12/4) · floating (32/16)`.

## 7. Wireframes

### Dashboard

```
┌────────────┬───────────────────────────────────────────────────────────────┐
│ ● ● ●      │  AULA Studio                                              ⌘  │
│            ├───────────────────────────────────────────────────────────────┤
│ ▣ Dashboard│  AULA F75Max-1                                  [Key Tester] │
│ ☼ Lighting │  (● Connected · Bluetooth)                                    │
│ ▤ Display  │  ┌──────────────────────────────────────────────────────────┐ │
│ ⌨ Keymap   │  │ ⚠ Bluetooth is view-only on this keyboard …              │ │
│ ◉ Macros   │  └──────────────────────────────────────────────────────────┘ │
│ ▦ Profiles │  ╭──────────────────────────────────────────────────────────╮ │
│ ▢ Firmware │  │  ┌────────────────────────────────────────┬────┬───┐ ┌─────────┐
│ ⚙ Settings │  │  │ Esc F1 … F12                            │TFT │ ◎ │ │ Key "A" │
│            │  │  │ ` 1 2 … = ⌫                         Del│    │   │ │  [ A ]  │
│            │  │  │ ⇥ Q W … \                           PgUp          │ usage   │
│            │  │  │ ⇪ A S … ↩                           PgDn          │ tested  │
│            │  │  │ ⇧ Z X … ⇧                        ↑  End           │ next…   │
│            │  │  │ ⌃ ⌥ ⌘ ␣␣␣␣␣␣ ⌘ Fn ⌃              ← ↓ →            └─────────┘
│            │  │  └──────────────────────────────────────────────┘      │ │
│            │  ╰──────────────────────────────────────────────────────────╯ │
│┌──────────┐│  ┌Keyboard┐ ┌Connection┐ ┌Battery┐ ┌Profile┐                 │
││⌁ F75Max  ▭││  ┌Lighting┐ ┌Brightness┐ ┌Polling┐ ┌Firmware┐ ┌Sleep┐        │
│└──────────┘│  [Key Tester card: coverage ▓▓▓░░ 42/80 · live event log]     │
└────────────┴───────────────────────────────────────────────────────────────┘
```

### Lighting

```
┌────────────┬──────────────────────────────────────────────┬───────────────┐
│ sidebar    │ Lighting                                     │ Color         │
│            │ ⓘ Preview only …                             │ ● ● ● ● ●     │
│            │ ╭ keyboard stage ───────────────────────────╮ │ ● ● ● ● ○     │
│            │ ╰───────────────────────────────────────────╯ │ ═══hue═══○══  │
│            │ Effects                                      │ [#6E7BFF] [■] │
│            │ ┌Off─┐┌Static┐┌React┐┌Fade┐┌Glitter┐        │ Multicolor ◯  │
│            │ ┌Rain┐┌Colour┐┌Breath┐┌Spectrum┐┌Outward┐    │ Adjust        │
│            │ ┌Wave┐┌Roll┐┌Rotate┐┌Explode┐┌Launch┐        │ Brightness ─● │
│            │ ┌Ripple┐┌Flow┐┌Pulse┐┌Tilt┐┌Shuttle┐         │ Speed ───●─   │
│            │                                              │ [→|↓|←|↑]     │
└────────────┴──────────────────────────────────────────────┴───────────────┘
```

### Display Studio (Phase 6)

```
┌ Library ─────────┬──── Canvas 128×128 (pixel grid on zoom) ────┬ Adjust ──────┐
│ ▢ clock.gif      │                                              │ Crop  Fit ▾  │
│ ▢ cat.png        │            ┌──────────────┐                  │ Scale  ───●  │
│ ▢ + Import       │            │              │                  │ Rotate ──●─  │
│ Widgets          │            │   preview    │                  │ Bright ──●─  │
│ ◷ Clock ⚡ Batt   │            │              │                  │ Contrast ─●  │
│ ▦ CPU  ▤ RAM     │            └──────────────┘                  │ Frame ms  80 │
│ ✎ Pixel editor   │   ◀ ▮▮ ▶  frames: ▢▢▢▢▢▢▢▢  onion ◯          │ [Send to KB] │
└──────────────────┴──────────────────────────────────────────────┴──────────────┘
```

### Macro timeline (Phase 7)

```
┌ Macros ────────┬───────────────────────────────────────────────────────────────┐
│ ▶ Deploy       │  ● Record   ▶ Test   Loop ×3   App: Any ▾                     │
│   Git commit   │  0ms     100      200      300      400                       │
│   Figma export │  ⌘ ▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇                                       │
│ + New          │  S       ▇▇▇▇                                                 │
│                │  delay            ░░░░░░ 120ms                                 │
│                │  ↩                        ▇▇                                  │
└────────────────┴───────────────────────────────────────────────────────────────┘
```

## 8. Accessibility plan

| Requirement | Approach | Status |
|---|---|---|
| VoiceOver | Keyboard canvas exposes 81 per-key accessibility children with frames, names and actions. Cards combine into label/value. | ✅ |
| Keyboard navigation | Arrow keys move key selection, Esc clears, ⌘K palette, ⌘1–8 | ✅ |
| Reduce Motion | All UI animation via `Motion.animation(_:reduceMotion:)` | ✅ UI · LED preview still animates, since it's content |
| High contrast | Semantic palette resolves the high-contrast appearances | ✅ basic |
| Dynamic Type | Text-style-based fonts | ✅ |
| Color independence | Status uses icon and text, not just color | ✅ |
