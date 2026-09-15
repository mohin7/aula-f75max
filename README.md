# AULA Studio

**An unofficial, open-source macOS app for the AULA F75 Max keyboard.**
AULA doesn't make software for Mac, so this app fills the gap. It's built natively with SwiftUI, IOKit and CoreBluetooth: no Electron, no web views, no kernel drivers.

[![License: MIT](https://img.shields.io/badge/License-MIT-blue.svg)](LICENSE)
![macOS 15+](https://img.shields.io/badge/macOS-15%2B-black)
![Apple silicon and Intel](https://img.shields.io/badge/Mac-Apple%20silicon%20%7C%20Intel-lightgrey)

> ⚠️ **Independent project.** It isn't made, endorsed or supported by AULA or Epomaker. See the [disclaimer](#disclaimer).

## Features

- **Lighting:** all 20 built-in effects, color, brightness, speed and direction, with a live preview.
- **Screen:** upload pictures and animated GIFs (up to 255 frames) to the 128×128 display.
- **Clock:** syncs automatically when you plug in, with optional 12-hour display.
- **Keyboard settings:** key response time, sleep timer, Windows/Alt+F4/Alt+Tab locks, Fn switch.
- **Battery:** live level over Bluetooth, with the last reading remembered.
- **Live preview:** an on-screen F75 Max that mirrors your key presses and knob turns, plus a Key Tester.
- **Menu bar companion** and a **⌘K command palette.**

Changes are made over the **USB-C cable**, and the keyboard keeps them when you switch back to Bluetooth.

## Download

Get the latest `.dmg` from [**Releases**](https://github.com/mohin7/aula-f75max/releases). The app isn't notarized by Apple yet, so the first time you open it, go to **System Settings → Privacy & Security → Open Anyway**.

## Privacy

AULA Studio has **no network access**: no analytics, no telemetry, no accounts. Key presses are only used to animate the on-screen keyboard and are never recorded or stored. See [SECURITY.md](SECURITY.md).

## Build and run

Needs macOS 15+ and Swift 6 (Xcode or Command Line Tools).

```sh
make run         # fast dev loop (unbundled)
make app         # build/AULA Studio.app (release, ad-hoc signed)
make open        # package and launch
make test        # unit tests (swift-testing)
make endpoints   # list the keyboard's HID interfaces
make keys        # stream live key and knob events (needs Input Monitoring)
```

Hardware CLI (USB-C):
```sh
.build/debug/aulactl clock                          # sync the keyboard clock
.build/debug/aulactl rgb 7 '#00FF00' 5 3            # effect, color, brightness, speed
.build/debug/aulactl settings --response 2 --sleep 2
.build/debug/aulactl upload picture.gif fill        # add --trace to any command to see packets
```

No keyboard? Run `AULA_DEMO=1 make run`, or turn on **Settings → Developer → Demo keyboard**.

The Makefile handles two Command Line Tools quirks automatically: it builds against the macOS 26 SDK (the 27 SDK's `@State` macro plugin ships only with Xcode), and it passes the swift-testing plugin path.

## Connection modes

| | USB-C | 2.4G | Bluetooth |
|---|---|---|---|
| Live key preview | ✅ | ✅ | ✅ |
| Lighting, screen upload, clock, settings | ✅ | coming soon | ❌ not supported by the keyboard (AULA's driver says the same) |
| Battery level | — | — | ✅ |

Over Bluetooth the F75 Max exposes no configuration channel (verified). Details: [Docs/Hardware-Protocol-Notes.md](Docs/Hardware-Protocol-Notes.md).

## Architecture

```
Sources/
├── AulaKit/                  Hardware and domain. No UI. Unit-tested.
│   ├── HID/                  IOKit discovery, key events, USB-C driver (lighting, settings, clock, screen)
│   ├── Bluetooth/            Battery and firmware over Bluetooth
│   ├── Protocol/             Packet builders with golden-byte tests
│   ├── Display/              Image and GIF encoder for the 128×128 screen
│   ├── Keymap/               HID usages, layout model, F75 Max layout
│   └── RGB/                  LEDColor, firmware lighting modes, preview engine
├── AulaDesignSystem/         Tokens (spacing, radius, type, palette, motion) and components
├── AULAStudio/               The app (MVVM, feature-first)
│   ├── App/                  @main, composition root (DI)
│   ├── Services/             KeyboardStore, KeyboardControl (USB-C writes), demo sources
│   ├── Navigation/           Sections, router, sidebar, ⌘K palette
│   ├── Components/Keyboard/  KeyboardStage, LEDLightView, DisplayScreenPreview
│   └── Features/             Dashboard, Lighting, Display, Settings, MenuBar
└── aulactl/                  Developer CLI for HID diagnostics
Tests/
├── AulaKitTests/             Layout geometry, colors, lighting engine, endpoint classification
└── AulaDesignSystemTests/    Token invariants, toast queue
Docs/                         Phase docs, protocol notes, roadmap
```

**Dependency rule:** `AULAStudio → AulaKit, AulaDesignSystem`. AulaKit and AulaDesignSystem never import each other.

**Data flow:** IOKit callbacks (main run loop) → `DeviceDiscovering` / `KeyEventSource` protocols → `KeyboardStore` (`@Observable`, `@MainActor`) → views. Hardware sources are injected, so demo mode and tests can swap them out.

## Keyboard renderer

`KeyboardStage` stacks four layers so that each one redraws only when needed:

1. **LED light:** `LEDLightView`. A `CADisplayLink` paints each key as a flat block in a 96×38 bitmap (6 px per key unit), and Core Animation upscales it; bilinear filtering gives the bloom. It stops for static effects and skips frames while the window is occluded.
2. **Keycaps:** a `Canvas` redrawn on press, hover or selection.
3. **Legends:** text, redrawn on press or legend-mode change.
4. **Hit testing and accessibility:** hover, click, ⌘-click, drag-paint selection, arrow-key navigation, and 81 VoiceOver elements.

## Contributing

Contributions are welcome, especially testing on other AULA keyboards. Please read [CONTRIBUTING.md](CONTRIBUTING.md) first; it includes the legal ground rules (no vendor files and no decompiled code). Report security issues privately as described in [SECURITY.md](SECURITY.md).

## Author

Built by **mohin7**.

- GitHub: [github.com/mohin7](https://github.com/mohin7)
- LinkedIn: [linkedin.com/in/mohin7](https://www.linkedin.com/in/mohin7/)

## Credits

Early protocol notes built on the MIT-licensed community project [VitalyArt/Aula-F75-Max-Driver](https://github.com/VitalyArt/Aula-F75-Max-Driver). No code was copied. Every command AULA Studio uses has been verified on real hardware.

## License

[MIT](LICENSE) © 2026 mohin7

## Disclaimer

- **Unofficial.** AULA Studio isn't affiliated with, endorsed by or supported by AULA, Epomaker or their partners. "AULA", "F75 Max" and "Epomaker" are trademarks of their respective owners and are used here only to describe which hardware this app works with.
- **Built for interoperability.** The app talks to the keyboard using protocol behavior observed on hardware the author owns, so that Mac users can use features that otherwise need Windows. It contains no vendor code, firmware or assets.
- **Use at your own risk.** The software is provided "as is", without warranty of any kind (see [LICENSE](LICENSE)). It never flashes firmware, but changing keyboard settings is your responsibility. Tested only on an F75 Max with its 2024 firmware.
