import AulaKit
import Foundation

let usage = """
usage: aulactl <command>

commands:
  endpoints   List every HID interface the AULA keyboard exposes, grouped by link
  keys        Stream live key and knob events from the keyboard (needs Input Monitoring)
  clock [--12h]
              USB-C: set the keyboard display clock to this Mac's time (--12h sends the hour as 1-12)
  rgb <mode> [#RRGGBB] [brightness 1-5] [speed 1-5]
              USB-C: set a firmware lighting effect (mode 0-19, see Docs/Hardware-Protocol-Notes.md)
  settings [--response 1-5] [--sleep 0-3] [--no-win] [--no-altf4] [--no-alttab] [--fn-switch]
              USB-C: write key response time, sleep time (0 never, 1 1min, 2 5min, 3 30min) and key locks
  upload <image-or-gif> [fit|fill|stretch]
              USB-C: upload a picture or animated GIF to the 128x128 screen
  raw "<hex>" ["<hex>" ...]
              USB-C research: send packets (zero-padded to 64 bytes), reading a reply after each.
              WARNING: sends arbitrary bytes to the keyboard. Never paste commands from untrusted sources.

flags:
  --trace     print every packet sent and every reply
  --exchange  read a reply after every packet
  --slow      wait 150 ms between packets that don't read a reply
"""

func printEndpoints() {
    let endpoints = HIDDeviceMonitor.snapshot()
    let keyboards = ConnectedKeyboard.group(endpoints)
    guard !keyboards.isEmpty else {
        print("No AULA F75 Max found (looked for USB 0C45:800A and 05AC:024F over USB/BLE).")
        exit(1)
    }
    for keyboard in keyboards {
        print("\(keyboard.productName) via \(keyboard.kind.title)"
            + (keyboard.hidVersion.map { "  (HID version \($0))" } ?? ""))
        print("  configuration channel: \(keyboard.hasConfigurationChannel ? "yes" : "no")")
        let caps = DeviceCapabilities.all.filter { keyboard.capabilities.contains($0.0) }.map(\.1)
        print("  capabilities: \(caps.joined(separator: ", "))")
        for e in keyboard.endpoints {
            let line = String(
                format: "  %04X:%04X  page 0x%04X usage 0x%02X  in %4d  out %4d  feature %4d  %@",
                e.vendorID, e.productID, e.usagePage, e.usage,
                e.maxInputReportSize, e.maxOutputReportSize, e.maxFeatureReportSize,
                e.role.rawValue
            )
            print(line)
        }
    }
}

@MainActor
func streamKeys() {
    var access = InputMonitoringAccess.current
    if access == .notDetermined { access = InputMonitoringAccess.request() }
    guard access == .granted else {
        print("Input Monitoring permission is required for the app running aulactl (e.g. Terminal).")
        print("System Settings → Privacy & Security → Input Monitoring")
        exit(2)
    }
    let monitor = KeyEventMonitor()
    let layout = KeyboardLayout.f75Max
    monitor.onEvent = { event in
        let keys = layout.keys(for: event.usage).map(\.id)
        let position = keys.isEmpty ? "(not in layout)" : keys.joined(separator: ",")
        print("\(event.isDown ? "↓" : "↑") \(event.usage)  \(event.usage.name.padding(toLength: 18, withPad: " ", startingAt: 0)) \(position)")
    }
    guard monitor.start() == .granted else {
        print("Could not open the keyboard for listening.")
        exit(2)
    }
    print("Listening. Press keys on the AULA keyboard, Ctrl-C to stop.")
    withExtendedLifetime(monitor) { RunLoop.main.run() }
}

let arguments = Array(CommandLine.arguments.dropFirst()).filter { !$0.hasPrefix("--") }
let flags = Set(CommandLine.arguments.dropFirst().filter { $0.hasPrefix("--") })

@Sendable func printPacket(sent: Bool, bytes: [UInt8]) {
    // Trim trailing zeros for readability.
    let used = max((bytes.lastIndex { $0 != 0 } ?? -1) + 1, 2)
    let hex = bytes.prefix(used).map { String(format: "%02X", $0) }.joined(separator: " ")
    print((sent ? "→ " : "← ") + hex)
}

func runDriver(_ label: String, _ body: @escaping @Sendable (WiredKeyboardDriver) async throws -> Void) async {
    let trace: (@Sendable (Bool, [UInt8]) -> Void)? = flags.contains("--trace") ? printPacket : nil
    let driver = WiredKeyboardDriver(
        sendInterval: flags.contains("--slow") ? .milliseconds(150) : .milliseconds(40),
        alwaysExchange: flags.contains("--exchange"),
        trace: trace
    )
    do {
        try await body(driver)
        print("✓ \(label)")
        exit(0)
    } catch {
        print("✗ \(label): \(error.localizedDescription)")
        exit(1)
    }
}

/// "04 18" → [0x04, 0x18]
func parseHex(_ text: String) -> [UInt8]? {
    let tokens = text.split(whereSeparator: { $0 == " " || $0 == ":" })
    let bytes = tokens.compactMap { UInt8($0, radix: 16) }
    return bytes.count == tokens.count ? bytes : nil
}

switch arguments.first {
case "endpoints": printEndpoints()
case "keys": streamKeys()
case "clock":
    let twelveHour = flags.contains("--12h")
    await runDriver("Clock synced to \(Date().formatted(date: .omitted, time: .standard))\(twelveHour ? " (12-hour)" : "")") {
        try await $0.syncClock(twelveHour: twelveHour)
    }
case "rgb":
    guard arguments.count >= 2, let raw = Int(arguments[1]), let mode = LightingMode(rawValue: raw) else {
        print(usage); exit(64)
    }
    var settings = LightingSettings(mode: mode)
    if arguments.count >= 3, let color = LEDColor(hex: arguments[2]) { settings.color = color }
    if arguments.count >= 4, let level = Int(arguments[3]) { settings.brightness = level }
    if arguments.count >= 5, let level = Int(arguments[4]) { settings.speed = level }
    let applied = settings
    await runDriver("Lighting: \(mode.title) \(applied.color.hexString) brightness \(applied.brightness) speed \(applied.speed)") {
        try await $0.applyLighting(applied)
    }
case "settings":
    func option(_ name: String) -> Int? {
        guard let index = CommandLine.arguments.firstIndex(of: name), index + 1 < CommandLine.arguments.count else { return nil }
        return Int(CommandLine.arguments[index + 1])
    }
    let settings = KeyboardSettings(
        responseLevel: option("--response") ?? 2,
        sleepTime: option("--sleep").flatMap(KeyboardSettings.SleepTime.init) ?? .fiveMinutes,
        disableWindowsKey: flags.contains("--no-win"),
        disableAltF4: flags.contains("--no-altf4"),
        disableAltTab: flags.contains("--no-alttab"),
        fnSwitch: flags.contains("--fn-switch")
    )
    await runDriver("Settings: response \(settings.responseLevel), sleep \(settings.sleepTime.title)") {
        try await $0.applySettings(settings)
    }
case "upload":
    guard arguments.count >= 2 else { print(usage); exit(64) }
    let url = URL(fileURLWithPath: arguments[1])
    let fit = arguments.count >= 3 ? DisplayEncoder.FitMode(rawValue: arguments[2]) ?? .fit : .fit
    do {
        let frames = try DisplayEncoder.frames(from: Data(contentsOf: url), fit: fit)
        let stream = DisplayEncoder.stream(for: frames)
        let chunks = stream.count / DisplayEncoder.chunkLength
        print("\(frames.count) frame(s), \(chunks) chunk(s)")
        await runDriver("Uploaded \(url.lastPathComponent)") { driver in
            let acknowledged = try await driver.uploadDisplay(stream) { progress in
                if progress.sentChunks % 20 == 0 || progress.sentChunks == progress.totalChunks {
                    print("  \(progress.sentChunks)/\(progress.totalChunks)")
                }
            }
            print("  keyboard acknowledged \(acknowledged)/\(chunks) chunks")
        }
    } catch {
        print("✗ \(error.localizedDescription)")
        exit(1)
    }
case "raw":
    // Each argument is one 64-byte packet in hex, zero-padded. Every packet reads a reply.
    let packets = arguments.dropFirst().map(parseHex)
    guard !packets.isEmpty, packets.allSatisfy({ $0 != nil }) else { print(usage); exit(64) }
    let steps = packets.map { AulaWiredProtocol.Step($0!, .exchange) }
    await runDriver("Sent \(steps.count) packet(s)") { try await $0.send(steps) }
default: print(usage)
}
