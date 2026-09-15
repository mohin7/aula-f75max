# Roadmap and phase status

| Phase | Scope | Status |
|---|---|---|
| 1 | UX architecture, IA, flows, components, tokens, wireframes | ✅ `Docs/01-UX-Architecture.md` |
| 2 | SwiftUI design system | ✅ `Sources/AulaDesignSystem` |
| 3 | Keyboard visualization | ✅ `KeyboardStage`, `LEDLightView`, `DisplayScreenPreview`, Key Tester |
| 4 | USB/2.4G HID communication | ✅ USB-C transport with the verified handshake and ack checks, plus Bluetooth GATT battery and firmware. 2.4G receiver still to do. |
| 5 | RGB engine (device writes, per-key editor, timeline) | 🟡 All 20 firmware effects write to the keyboard. Per-key and real-time streaming (`04 20`) are decoded but not built. |
| 6 | Display engine (RGB565 encoder, upload, widgets, pixel editor) | 🟡 Image and GIF upload verified (251 frames, 2009/2009 chunks acknowledged). Widgets and pixel editor to do. |
| 7 | Keymap and macro engine | ⏳ Mac-side first. On-board needs protocol capture. |
| 8 | Firmware updater | ⛔ Blocked on vendor firmware images and DFU docs |
| 9 | Settings persistence, profiles, per-app switching, automations | 🟡 Keyboard settings (response, sleep, Win/Alt+F4/Alt+Tab locks, Fn switch) and clock sync with auto-sync work. Profiles to do. |
| 10 | Performance, tests, signing, notarization, DMG | ⏳ |

## Phase 4 plan (next)

1. `HIDTransport` actor: opens an endpoint, serializes SET/GET_REPORT, sets timeouts, handles disconnects, and logs reports in developer mode.
2. `AulaProtocol` packet builders (pure, golden-byte tested): checksum, RGB set/commit, response/sleep/game mode, battery query, clock sync, display header.
3. `KeyboardDriver` protocol with `WiredDriver` and `DongleDriver`, selected from `ConnectedKeyboard.kind`. The store talks only to the protocol.
4. Battery polling over 2.4G (60 s, plus on wake).
5. CoreBluetooth probe for GATT battery or config services.
6. `aulactl rgb|battery|clock` commands for hardware verification.
7. Capture session for the open questions in `Hardware-Protocol-Notes.md`.

## Known deviations from the original brief

| Brief | Decision | Why |
|---|---|---|
| SwiftData | JSON files and `UserDefaults` for now | SwiftData's `@Model` macro plugin ships only with Xcode. This machine has Command Line Tools only. With Xcode installed, Phase 9 can adopt SwiftData behind the same repository protocol. |
| Top navigation | Sidebar | macOS HIG for 8+ peer sections, plus the device footer |
| Music Sync, CPU, Fire, Ocean, Aurora and similar RGB modes | Planned as **software-driven** effects | They aren't firmware modes. They need per-key streaming, which depends on the per-key protocol (open question 2). |
| Bluetooth device manager (rename, switch hosts) | Show paired status only | The keyboard exposes no host-switching protocol. Switching uses Fn+1/2/3 on the hardware. |
| Firmware update, rollback | Blocked | No public images or bootloader protocol, and a real risk of bricking |
| 60 fps LED preview, < 120 MB | Measured, see below | |

## Measured performance (release build, M-series, 1280×840 window)

| Scenario | CPU | Memory footprint |
|---|---|---|
| Static lighting (idle) | ~0% | ~81 MB |
| Animated effect at display refresh | ~7–11% | ~66 MB |

First attempt (SwiftUI `TimelineView` + `Canvas`): 26–35% CPU, 190–205 MB. Moving the LED layer to a display-link-driven `CALayer` with a tiny upscaled bitmap removed SwiftUI's per-frame layout pass.
