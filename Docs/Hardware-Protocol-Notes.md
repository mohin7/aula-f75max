# F75 Max hardware and protocol notes

What we know, how we know it, and what's still open. **Verified** means observed on the real keyboard in this project.

## Verified on hardware (2026-09-15, macOS 26.6.2)

Keyboard paired over **Bluetooth LE**:

| Property | Value |
|---|---|
| Product | `AULA F75Max-1` |
| Vendor / Product ID | `0x05AC` / `0x024F` (Apple's vendor ID, same as the 2.4G receiver) |
| Transport | `Bluetooth Low Energy` |
| VersionNumber (bcdDevice) | `0x0138` (shown as "v1.38") |
| Manufacturer / Serial / FW strings | SDK placeholders: `"Manufacturer Name"`, `"Serial Number"`, `"Firmware Revision"` |
| HID interfaces | One IOHIDDevice: keyboard (1/6), consumer (12/1), plus vendor usage `0xFF00/0x03` for one bit of input only |
| Max report sizes | in 16 · out 2 · feature 1 |
| Battery | Not in IORegistry and not in `system_profiler SPBluetoothDataType` |

The report descriptor over BLE has IDs: 2 (6KRO keyboard), 1 (system control), 3 (mouse), 8 (consumer, 16-bit array: knob volume and media), 5 (NKRO bitmap), 0x11 (consumer bits + one vendor bit), 9 (digitizer or dial).
**There's no vendor output or feature report in the HID map.** CoreBluetooth shows more at the GATT level, though.

### Bluetooth GATT (verified with CoreBluetooth)

| Service | Characteristic | Props | Value / notes |
|---|---|---|---|
| 0x180A Device Information | 0x2A28 Software Revision | read | `2024.07.26 SVN0138` (the other strings are SDK placeholders) |
| | 0x2A50 PnP ID | read | `01 AC05 4F02 3801`: VID 05AC, PID 024F, v1.38 |
| | 0x2A2A Regulatory | read | `FE 00 "experimental"` |
| 0x180F Battery | 0x2A19 Battery Level | read, notify | **Read → 94% (stale), notify every ~5 s → 36% (correct: the keyboard screen showed 35%).** Use notifications only. Report Reference descriptor `04 01` (HID input report 4). |
| 0x1813 Scan Parameters | 0x2A4F / 0x2A31 | write / notify | Standard, not useful |
| **0xFEE0 vendor** | **0xFEE1** | read, write, writeNoResp | **Possible settings channel.** Reads are empty. MTU: 512 with response, 73 without. |

Experiment log:
- 2026-09-15: wrote the 2.4G battery query (`20 01 00… 21`, 32 bytes, with response) to FEE1. The write was accepted, FEE1 read back empty, and the keyboard kept working normally. No other writes have been made.
- Caution: on many BLE SoCs, 0xFEE0/FEE1 is also the **vendor OTA (firmware update) service**. Don't write speculative bytes there. Next step is capturing traffic from AULA's official software, or confirming with visible, reversible commands.

The HID descriptor over BLE is only part of the picture. The app reads battery and firmware through `BluetoothKeyboardMonitor`.

Run `make endpoints` to repeat this for any link.

## Verified on hardware over USB-C (2026-09-15)

Every command in this section was confirmed on a retail F75 Max: the keyboard acknowledged it and the change was visible (lighting, clock, settings, screen upload). AULA's own Windows utility also says that keyboard settings aren't supported in Bluetooth mode, which matches what we observed.

Device facts: USB `0C45:800A` and 2.4G receiver `05AC:024F`. Brightness and speed levels run 1–5, the default effect is 11, and the screen is 128×128 with up to 255 frames and a 256-byte header.

### Handshake
Wait about 35 ms before each 64-byte feature SET_REPORT (report ID 0). For control commands, wait about 35 ms again and GET_REPORT: **the command was accepted when reply byte 3 == 0x01**. Reading the reply right away returns only an echo (byte 3 = 0x00), which looks like success but isn't.

### Lighting ✅
| # | Packet | Ack |
|---|---|---|
| 1 | `04 18` | yes |
| 2 | `04 13 00 00 00 00 00 00 01` | yes |
| 3 | `mode R G B 00 00 00 00 colorful brightness speed direction 00 00 AA 55` | no |
| 4 | `04 02` | yes (reply `04 02 00 01 07 02`) |
| 5 | `04 F0` | no |

### Clock ✅
`04 18` (ack) → `04 28 … [8]=01` (ack) → `00 <slot> 5A <year−2000> month day hour minute second 00 weekday(0=Sun) … AA 55` (the reply echoes the data, so there's no ack flag; read it anyway) → `04 02` (ack).
Byte 1 is the screen slot (1-based). **There's no 12/24-hour field**: the clock style is fixed in firmware. AULA Studio's optional 12-hour mode sends the hour as 1–12 and re-syncs on the hour.

### Keyboard settings ✅
`04 18` (ack) → `04 17 01 … [8]=01` (ack) → `00 01 winLock altF4Lock altTabLock fnSwitch sleep 00 responseLevel … AA 55` → `04 02` (ack).
Sleep: 0 = never, 1 = 1 min, 2 = 5 min, 3 = 30 min. Response level: 1–5.

### Screen upload ✅
`04 18` (ack) → `04 72 <slot> … [8..9]=chunkCount LE` (ack) → 4096-byte output reports on `0xFF68`, each acknowledged by an input report → `04 02` (ack). About 145 ms per chunk.

## From community reverse-engineering (not yet verified here)

Source: [VitalyArt/Aula-F75-Max-Driver](https://github.com/VitalyArt/Aula-F75-Max-Driver) (MIT). We reuse **facts** (IDs, byte layouts) and no code. Each packet builder gets verified with a hardware capture before release.

### IDs and endpoints

| Link | VID:PID | Command page | Data page |
|---|---|---|---|
| USB-C | `0C45:800A` | `0xFF13`: 64-byte **feature** reports | `0xFF68`: 4096-byte **output** reports (display), 128-byte input acks |
| 2.4G receiver | `05AC:024F` | `0xFF59` | `0xFF60`: 32-byte **output** reports |

### Checksum

Wireless reports: byte 31 = low 8 bits of the sum of all bytes (computed with byte 31 set to 0).

### 2.4G reports (32 bytes)

| Purpose | Layout |
|---|---|
| RGB commit (sent first) | `[0]=0x0F`, checksum |
| RGB set | `05 10 00 mode R G B …; [11]=colorful [12]=brightness(1–5) [13]=speed(1–5) [14]=direction(0–3) [17]=AA [18]=55`, checksum |
| Response, sleep, Fn | `07 10 00 00 01 01 01 01 fn sleep(0=none,1=1m,2=5m,3=30m) _ level(1–5) … [17]=AA [18]=55`, checksum |
| Game Mode | Response report + `[12]=game [13]=disableAltTab [14]=disableAltF4 [15]=disableWin` |
| Battery query | `20 01 …` with checksum → input report `20 01 ?? percent` |

Response levels over 2.4G: 1 ≈ 5–6 ms, 2 ≈ 7–9 ms, 3 ≈ 10–12 ms, 4 ≈ 15–17 ms, 5 ≈ 19–21 ms.

### USB-C command flow (64-byte feature reports, each followed by GET_REPORT)

```
04 18                 begin
04 <block> … [8]=n    select block, n pages follow
<payload pages>
04 02                 apply
04 F0                 finish/commit (some blocks)
```

| Block | Meaning |
|---|---|
| `04 13` | Lighting: see the verified section above ✅ |
| `04 28` + time packet | Clock: `00 01 5A 1A month day hour min sec _ weekday … [62]=AA [63]=55` |
| `04 72` `[2]=slot [8..9]=chunkCount LE` | Display upload header, then chunks on `0xFF68` |
| `04 11` (9 pages) | Keymap and macro storage (seen only as zeroed during factory reset). **Layout unknown.** |
| `04 27` (9 pages) | Lighting storage, likely per-key. **Layout unknown.** |
| `04 15`, `04 17`, `04 19` | Display slots and config reset |

### Display stream

- 128 × 128, **RGB565 little-endian**
- 256-byte header: `[0]=frameCount`, `[1…]=per-frame delay` (seconds × 500, clamped to 1–255)
- Then `frameCount × 32 768` bytes, zero-padded to 4096-byte chunks, max 255 frames

### Lighting modes (index → firmware name)

0 Off · 1 Static · 2 SingleOn · 3 SingleOff · 4 Glittering · 5 Falling · 6 Colourful · 7 Breath · 8 Spectrum · 9 Outward · 10 Scrolling · 11 Rolling · 12 Rotating · 13 Explode · 14 Launch · 15 Ripples · 16 Flowing · 17 Pulsating · 18 Tilt · 19 Shuttle

## Open questions → Phase 4 capture plan

1. Lighting read-back over USB-C. Battery over USB-C?
2. Per-key RGB: the layout of block `04 27`.
3. On-board keymap: the layout of block `04 11`, including knob actions.
4. Win/Mac mode: which usages the right-hand modifiers send in Mac mode (layout remap assumes `E7 → E6`).
5. BLE: does FEE0/FEE1 accept the 2.4G command format (lighting `05 10 …`), or is it OTA-only?
6. Does sending to `0xFF13` need Input Monitoring? (IOKit may return `kIOReturnNotPermitted` for keyboards.)

Method: observe the keyboard's USB traffic for single-setting changes on hardware you own → encode as golden-byte unit tests in `AulaKitTests` → verify on hardware with `aulactl`.

## Safety rules

- Never write firmware or bootloader regions. Firmware update stays blocked until vendor images and a documented DFU flow exist.
- Every write command goes through a typed packet builder with golden-byte tests. No raw byte arrays in feature code.
- A factory-reset path (known from the community flow) has to exist before any storage-block writes (`04 11`, `04 27`).
