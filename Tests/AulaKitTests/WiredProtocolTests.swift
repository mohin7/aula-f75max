import CoreGraphics
import Foundation
import ImageIO
import Testing
@testable import AulaKit

@Suite("USB-C command protocol")
struct WiredProtocolTests {
    private func hex(_ bytes: [UInt8]) -> String {
        bytes.map { String(format: "%02X", $0) }.joined(separator: " ")
    }

    @Test func everyPacketIs64Bytes() {
        let steps = AulaWiredProtocol.clockSync(date: Date()) + AulaWiredProtocol.lighting(LightingSettings())
        #expect(steps.allSatisfy { $0.bytes.count == 64 })
    }

    @Test func acknowledgementFlag() {
        // Real replies from the keyboard with the official 35 ms pacing.
        #expect(AulaWiredProtocol.isAcknowledged([0x04, 0x18, 0x00, 0x01]))
        #expect(AulaWiredProtocol.isAcknowledged([0x04, 0x02, 0x00, 0x01, 0x07, 0x02]))
        // An immediate read just echoes the command back.
        #expect(!AulaWiredProtocol.isAcknowledged([0x04, 0x18, 0x00, 0x00]))
        #expect(!AulaWiredProtocol.isAcknowledged([0x04, 0x18]))
    }

    @Test func clockSyncSequence() throws {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = TimeZone(identifier: "UTC")!
        // Tuesday 2026-09-15 20:45:07 UTC
        let date = try #require(calendar.date(from: DateComponents(year: 2026, month: 9, day: 15, hour: 20, minute: 45, second: 7)))
        let steps = AulaWiredProtocol.clockSync(date: date, calendar: calendar)

        #expect(steps.map(\.kind) == [.sendThenRead, .sendThenRead, .sendThenReadEcho, .sendThenRead])
        #expect(Array(steps[0].bytes.prefix(2)) == [0x04, 0x18])
        #expect(Array(steps[1].bytes.prefix(2)) == [0x04, 0x28])
        #expect(steps[1].bytes[8] == 0x01)
        #expect(hex(Array(steps[2].bytes.prefix(11))) == "00 01 5A 1A 09 0F 14 2D 07 00 02")
        #expect(Array(steps[2].bytes.suffix(2)) == [0xAA, 0x55])
        #expect(Array(steps[3].bytes.prefix(2)) == [0x04, 0x02])
    }

    @Test func sundayIsWeekdayZero() throws {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = TimeZone(identifier: "UTC")!
        let sunday = try #require(calendar.date(from: DateComponents(year: 2026, month: 9, day: 13, hour: 9)))
        #expect(AulaWiredProtocol.clockSync(date: sunday, calendar: calendar)[2].bytes[10] == 0)
    }

    @Test func lightingSequence() {
        let settings = LightingSettings(
            mode: .breathing, color: LEDColor(rgb: 0xFF0080), brightness: 4, speed: 2, direction: .left, multicolor: false
        )
        let steps = AulaWiredProtocol.lighting(settings)

        #expect(steps.map { Array($0.bytes.prefix(2)) } == [[0x04, 0x18], [0x04, 0x13], [0x07, 0xFF], [0x04, 0x02], [0x04, 0xF0]])
        // Verified handshake: acknowledge begin, select and apply only.
        #expect(steps.map(\.kind) == [.sendThenRead, .sendThenRead, .send, .sendThenRead, .send])
        #expect(steps[1].bytes[8] == 0x01)
        #expect(hex(Array(steps[2].bytes.prefix(16))) == "07 FF 00 80 00 00 00 00 00 04 02 02 00 00 AA 55")
        #expect(steps[2].bytes[16...].allSatisfy { $0 == 0 })
    }

    @Test func lightingOffClearsParameters() {
        let steps = AulaWiredProtocol.lighting(LightingSettings(mode: .off, color: .white, brightness: 5, speed: 5, multicolor: true))
        #expect(hex(Array(steps[2].bytes.prefix(16))) == "00 00 00 00 00 00 00 00 00 00 00 00 00 00 AA 55")
    }

    @Test func multicolorFlag() {
        let steps = AulaWiredProtocol.lighting(LightingSettings(mode: .scrolling, multicolor: true))
        #expect(steps[2].bytes[8] == 1)
    }
}


@Suite("Settings, clock and display")
struct DeviceFeatureTests {
    private func hex(_ bytes: ArraySlice<UInt8>) -> String {
        bytes.map { String(format: "%02X", $0) }.joined(separator: " ")
    }

    @Test func clockYearIsYearsSince2000() throws {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = TimeZone(identifier: "UTC")!
        let nextYear = try #require(calendar.date(from: DateComponents(year: 2027, month: 1, day: 2, hour: 3, minute: 4, second: 5)))
        #expect(AulaWiredProtocol.clockSync(date: nextYear, calendar: calendar)[2].bytes[3] == 27)
    }

    @Test func settingsFactoryDefaultsMatchOfficialResetPayload() {
        // Community factory reset writes: 00 01 00 00 00 00 02 00 02
        let steps = AulaWiredProtocol.settings(KeyboardSettings())
        #expect(hex(steps[1].bytes.prefix(9)) == "04 17 01 00 00 00 00 00 01")
        #expect(hex(steps[2].bytes.prefix(9)) == "00 01 00 00 00 00 02 00 02")
        #expect(Array(steps[2].bytes.suffix(2)) == [0xAA, 0x55])
        #expect(steps.map(\.kind) == [.sendThenRead, .sendThenRead, .send, .sendThenRead])
    }

    @Test func settingsFields() {
        let settings = KeyboardSettings(responseLevel: 5, sleepTime: .thirtyMinutes, disableWindowsKey: true, disableAltF4: false, disableAltTab: true, fnSwitch: true)
        #expect(hex(AulaWiredProtocol.settings(settings)[2].bytes.prefix(9)) == "00 01 01 00 01 01 03 00 05")
    }

    @Test func displayUploadHeader() {
        let steps = AulaWiredProtocol.displayUploadBegin(slot: 1, chunkCount: 0x0123)
        #expect(hex(steps[1].bytes.prefix(10)) == "04 72 01 00 00 00 00 00 23 01")
        #expect(hex(AulaWiredProtocol.displayUploadFinish[0].bytes.prefix(2)) == "04 02")
    }

    @Test func delayBytesUseTwoMillisecondUnits() {
        #expect(DisplayEncoder.delayByte(milliseconds: 100) == 50)
        #expect(DisplayEncoder.delayByte(milliseconds: 10) == 15)   // clamped to 30 ms
        #expect(DisplayEncoder.delayByte(milliseconds: 900) == 250) // clamped to 500 ms
    }

    @Test func singleRedFrameStream() throws {
        let context = try #require(CGContext(
            data: nil, width: 16, height: 8, bitsPerComponent: 8, bytesPerRow: 64,
            space: CGColorSpace(name: CGColorSpace.sRGB)!, bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue
        ))
        context.setFillColor(CGColor(srgbRed: 1, green: 0, blue: 0, alpha: 1))
        context.fill(CGRect(x: 0, y: 0, width: 16, height: 8))
        let png = NSMutableData()
        let destination = try #require(CGImageDestinationCreateWithData(png, "public.png" as CFString, 1, nil))
        CGImageDestinationAddImage(destination, try #require(context.makeImage()), nil)
        #expect(CGImageDestinationFinalize(destination))

        let frames = try DisplayEncoder.frames(from: png as Data, fit: .stretch)
        let stream = DisplayEncoder.stream(for: frames)
        #expect(frames.count == 1)
        #expect(stream.count % 4096 == 0)
        #expect(stream.count == 36_864) // 256 + 32 768 bytes → 9 chunks
        #expect(stream[0] == 1)
        #expect(stream[1] == 50) // default 100 ms
        // Pure red in RGB565 little-endian is 00 F8.
        #expect(stream[256] == 0x00 && stream[257] == 0xF8)
    }

    @Test func fitLetterboxesWideImages() {
        let rect = DisplayEncoder.drawRect(imageWidth: 256, imageHeight: 128, fit: .fit)
        #expect(rect == CGRect(x: 0, y: 32, width: 128, height: 64))
        let fill = DisplayEncoder.drawRect(imageWidth: 256, imageHeight: 128, fit: .fill)
        #expect(fill.height == 128 && fill.width == 256)
    }
}

@Suite("12-hour clock")
struct TwelveHourClockTests {
    private func hourByte(_ hour: Int, twelveHour: Bool) throws -> UInt8 {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = TimeZone(identifier: "UTC")!
        let date = try #require(calendar.date(from: DateComponents(year: 2026, month: 9, day: 15, hour: hour, minute: 13)))
        return AulaWiredProtocol.clockSync(date: date, calendar: calendar, twelveHour: twelveHour)[2].bytes[6]
    }

    @Test func twentyFourHourIsUnchanged() throws {
        #expect(try hourByte(22, twelveHour: false) == 22)
        #expect(try hourByte(0, twelveHour: false) == 0)
    }

    @Test(arguments: [(0, 12), (1, 1), (11, 11), (12, 12), (13, 1), (22, 10), (23, 11)])
    func twelveHourMapping(hour: Int, expected: UInt8) throws {
        #expect(try hourByte(hour, twelveHour: true) == expected)
    }
}
