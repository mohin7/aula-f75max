import Foundation

/// Packet builders for the USB-C command channel (usage page 0xFF13, 64-byte feature reports).
///
/// Pure functions with no I/O, so every command is covered by golden-byte tests.
/// Layouts are documented in `Docs/Hardware-Protocol-Notes.md` and marked as verified
/// once confirmed on hardware.
public enum AulaWiredProtocol {
    public static let packetLength = 64

    /// A command sequence. Each packet is one SET_REPORT.
    public struct Step: Equatable, Sendable {
        public enum Kind: Equatable, Sendable {
            /// Feature SET_REPORT, then GET_REPORT to read the acknowledgement right away.
            case exchange
            /// Feature SET_REPORT only, then a short pause.
            case send
            /// Feature SET_REPORT, a pause (the firmware may be writing flash), then GET_REPORT,
            /// which must carry the acknowledgement flag.
            case sendThenRead
            /// Like `sendThenRead`, for data packets: the reply echoes the data, so the flag isn't checked.
            case sendThenReadEcho
            /// Output SET_REPORT (interrupt OUT), then a short pause.
            case output
        }

        public let bytes: [UInt8]
        public let kind: Kind

        /// Pads or truncates to 64 bytes.
        public init(_ bytes: [UInt8], _ kind: Kind) {
            self.bytes = Array((bytes + [UInt8](repeating: 0, count: AulaWiredProtocol.packetLength)).prefix(AulaWiredProtocol.packetLength))
            self.kind = kind
        }
    }

    static func command(_ group: UInt8, _ code: UInt8, _ fields: [Int: UInt8] = [:]) -> [UInt8] {
        var packet = [UInt8](repeating: 0, count: packetLength)
        packet[0] = group
        packet[1] = code
        for (index, value) in fields { packet[index] = value }
        return packet
    }

    enum Command {
        static let begin: UInt8 = 0x18
        static let apply: UInt8 = 0x02
        static let finish: UInt8 = 0xF0
        static let selectLighting: UInt8 = 0x13
        static let selectSettings: UInt8 = 0x17
        static let selectClock: UInt8 = 0x28
        static let selectDisplayUpload: UInt8 = 0x72
    }

    // MARK: Clock

    /// Sets the display clock from the Mac's local time. The keyboard's clock format is fixed in firmware.
    /// Verified on hardware 2026-09-15.
    ///
    /// The firmware only has a 24-hour clock. With `twelveHour`, the hour is sent as 1–12 so the screen
    /// reads like a 12-hour clock (no AM/PM). The firmware still counts past 12, so the caller must
    /// re-sync on the hour.
    public static func clockSync(date: Date, calendar: Calendar = .current, twelveHour: Bool = false) -> [Step] {
        let parts = calendar.dateComponents([.year, .month, .day, .hour, .minute, .second, .weekday], from: date)
        var time = [UInt8](repeating: 0, count: packetLength)
        time[0] = 0x00
        time[1] = 0x01
        time[2] = 0x5A
        // Year since 2000. Community code hardcoded 0x1A, which only happens to be 2026.
        time[3] = UInt8(clamping: ((parts.year ?? 2000) - 2000) % 100)
        time[4] = UInt8(clamping: parts.month ?? 1)
        time[5] = UInt8(clamping: parts.day ?? 1)
        let hour = parts.hour ?? 0
        time[6] = UInt8(clamping: twelveHour ? (hour % 12 == 0 ? 12 : hour % 12) : hour)
        time[7] = UInt8(clamping: parts.minute ?? 0)
        time[8] = UInt8(clamping: parts.second ?? 0)
        // Calendar weekday is 1 = Sunday. The firmware wants 0 = Sunday.
        time[10] = UInt8(clamping: max((parts.weekday ?? 1) - 1, 0))
        time[62] = 0xAA
        time[63] = 0x55

        // Every packet is read back, including the time itself.
        return [
            Step(command(0x04, Command.begin), .sendThenRead),
            Step(command(0x04, Command.selectClock, [8: 0x01]), .sendThenRead),
            Step(time, .sendThenReadEcho),
            Step(command(0x04, Command.apply), .sendThenRead),
        ]
    }

    // MARK: Lighting

    /// Sets a firmware lighting effect. The keyboard stores it, so it survives switching to Bluetooth or 2.4G.
    ///
    /// Verified on hardware 2026-09-15. Handshake:
    /// begin and select read an acknowledgement, the payload doesn't, apply does, and the save doesn't.
    public static func lighting(_ settings: LightingSettings) -> [Step] {
        var payload = [UInt8](repeating: 0, count: packetLength)
        payload[0] = UInt8(settings.mode.rawValue)
        if settings.mode != .off {
            payload[1] = settings.color.red
            payload[2] = settings.color.green
            payload[3] = settings.color.blue
            payload[8] = settings.multicolor ? 1 : 0
            payload[9] = UInt8(settings.brightness)
            payload[10] = UInt8(settings.speed)
            payload[11] = UInt8(settings.direction.rawValue)
        }
        payload[14] = 0xAA
        payload[15] = 0x55

        return [
            Step(command(0x04, Command.begin), .sendThenRead),
            Step(command(0x04, Command.selectLighting, [8: 0x01]), .sendThenRead),
            Step(payload, .send),
            Step(command(0x04, Command.apply), .sendThenRead),
            Step(command(0x04, Command.finish), .send),
        ]
    }

    // MARK: Keyboard settings

    /// Writes key response time, sleep time and key locks. Verified on hardware 2026-09-15.
    public static func settings(_ settings: KeyboardSettings) -> [Step] {
        var payload = [UInt8](repeating: 0, count: packetLength)
        payload[0] = 0x00
        payload[1] = 0x01
        payload[2] = settings.disableWindowsKey ? 1 : 0
        payload[3] = settings.disableAltF4 ? 1 : 0
        payload[4] = settings.disableAltTab ? 1 : 0
        payload[5] = settings.fnSwitch ? 1 : 0
        payload[6] = UInt8(settings.sleepTime.rawValue)
        payload[8] = UInt8(settings.responseLevel)
        payload[62] = 0xAA
        payload[63] = 0x55

        return [
            Step(command(0x04, Command.begin), .sendThenRead),
            Step(command(0x04, Command.selectSettings, [2: 0x01, 8: 0x01]), .sendThenRead),
            Step(payload, .send),
            Step(command(0x04, Command.apply), .sendThenRead),
        ]
    }

    // MARK: Display upload

    /// Opens a screen upload of `chunkCount` 4096-byte chunks into `slot`. Verified on hardware 2026-09-15.
    /// Chunks then go to the 0xFF68 interface, followed by `displayUploadFinish`.
    public static func displayUploadBegin(slot: UInt8, chunkCount: Int) -> [Step] {
        [
            Step(command(0x04, Command.begin), .sendThenRead),
            Step(command(0x04, Command.selectDisplayUpload, [
                2: slot,
                8: UInt8(chunkCount & 0xFF),
                9: UInt8((chunkCount >> 8) & 0xFF),
            ]), .sendThenRead),
        ]
    }

    public static let displayUploadFinish = [Step(command(0x04, Command.apply), .sendThenRead)]

    /// The acknowledgement flag in a reply: byte 3 is 0x01 once the firmware has accepted the command.
    public static func isAcknowledged(_ reply: [UInt8]) -> Bool {
        reply.count > 3 && reply[3] == 0x01
    }
}
