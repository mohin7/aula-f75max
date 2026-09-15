import Foundation
import Testing
@testable import AulaKit

@Suite("Bluetooth GATT parsing")
struct BluetoothParsingTests {
    @Test func batteryLevelFromRealKeyboard() {
        // 0x5E read from the F75 Max Battery Level characteristic.
        #expect(BluetoothKeyboardMonitor.parseBatteryLevel(Data([0x5E])) == 94)
        #expect(BluetoothKeyboardMonitor.parseBatteryLevel(Data([0])) == 0)
        #expect(BluetoothKeyboardMonitor.parseBatteryLevel(Data([100])) == 100)
    }

    @Test func invalidBatteryValuesAreIgnored() {
        #expect(BluetoothKeyboardMonitor.parseBatteryLevel(Data()) == nil)
        #expect(BluetoothKeyboardMonitor.parseBatteryLevel(Data([101])) == nil)
        #expect(BluetoothKeyboardMonitor.parseBatteryLevel(Data([0x5E, 0x00])) == nil)
    }

    @Test func softwareRevisionFromRealKeyboard() {
        #expect(BluetoothKeyboardMonitor.parseString(Data("2024.07.26 SVN0138".utf8)) == "2024.07.26 SVN0138")
        #expect(BluetoothKeyboardMonitor.parseString(Data("SVN0138\0\0".utf8)) == "SVN0138")
    }

    @Test func sdkPlaceholderStringsAreDropped() {
        #expect(BluetoothKeyboardMonitor.parseString(Data("Firmware Revision".utf8)) == nil)
        #expect(BluetoothKeyboardMonitor.parseString(Data([0, 0, 0])) == nil)
    }
}
