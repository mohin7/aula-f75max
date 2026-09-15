@preconcurrency import CoreBluetooth
import Foundation

/// What the F75 Max exposes over standard Bluetooth LE GATT services.
///
/// Verified on hardware (firmware 2024.07.26 SVN0138):
/// - Battery Service 0x180F / Battery Level 0x2A19: read + notify. **Only notifications are
///   accurate.** A read returned a stale 94% while notifications (every ~5 s) said 36%, and the
///   keyboard's own screen showed 35%.
/// - Device Information 0x180A / Software Revision 0x2A28: "2024.07.26 SVN0138".
/// - Vendor service 0xFEE0 / characteristic 0xFEE1: read, write and write-without-response.
///   Its protocol is unknown, see `Docs/Hardware-Protocol-Notes.md`.
public struct BluetoothKeyboardInfo: Equatable, Sendable {
    public var name: String
    public var batteryLevel: Int?
    public var softwareRevision: String?
    public var hasVendorService: Bool

    public init(name: String, batteryLevel: Int? = nil, softwareRevision: String? = nil, hasVendorService: Bool = false) {
        self.name = name
        self.batteryLevel = batteryLevel
        self.softwareRevision = softwareRevision
        self.hasVendorService = hasVendorService
    }
}

@MainActor
public protocol BluetoothKeyboardInfoSource: AnyObject {
    /// `nil` when no AULA keyboard is connected over Bluetooth, or Bluetooth access is denied.
    var onUpdate: (@MainActor (BluetoothKeyboardInfo?) -> Void)? { get set }
    /// Looks for the system-connected keyboard. Call again whenever HID discovery changes.
    func refresh()
    func stop()
}

/// Reads battery and firmware from the system-paired keyboard over standard GATT services.
/// Only reads and subscribes. It never writes to the keyboard.
/// Needs Bluetooth permission (`NSBluetoothAlwaysUsageDescription`).
@MainActor
public final class BluetoothKeyboardMonitor: NSObject, BluetoothKeyboardInfoSource {
    public var onUpdate: (@MainActor (BluetoothKeyboardInfo?) -> Void)?

    private enum UUIDs {
        static let battery = CBUUID(string: "180F")
        static let batteryLevel = CBUUID(string: "2A19")
        static let deviceInformation = CBUUID(string: "180A")
        static let softwareRevision = CBUUID(string: "2A28")
        static let vendor = CBUUID(string: "FEE0")
    }

    private var central: CBCentralManager?
    private var peripheral: CBPeripheral?
    private var info: BluetoothKeyboardInfo? {
        didSet { if info != oldValue { onUpdate?(info) } }
    }

    public override init() {
        super.init()
    }

    public func refresh() {
        guard let central else {
            // Creating the manager triggers the permission prompt on first use.
            central = CBCentralManager(delegate: self, queue: .main)
            return
        }
        guard central.state == .poweredOn else { return }

        let connected = central.retrieveConnectedPeripherals(withServices: [UUIDs.battery])
            .first { ($0.name ?? "").localizedCaseInsensitiveContains("AULA") }

        guard let connected else {
            if let peripheral { central.cancelPeripheralConnection(peripheral) }
            peripheral = nil
            info = nil
            return
        }
        guard connected.identifier != peripheral?.identifier else { return }

        peripheral = connected
        info = BluetoothKeyboardInfo(name: connected.name ?? "AULA F75 Max")
        connected.delegate = self
        // The system already holds the link. This just gives us a GATT client on it.
        central.connect(connected)
    }

    public func stop() {
        if let peripheral { central?.cancelPeripheralConnection(peripheral) }
        peripheral = nil
        info = nil
    }
}

extension BluetoothKeyboardMonitor: @preconcurrency CBCentralManagerDelegate {
    public func centralManagerDidUpdateState(_ central: CBCentralManager) {
        if central.state == .poweredOn {
            refresh()
        } else {
            peripheral = nil
            info = nil
        }
    }

    public func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        peripheral.discoverServices([UUIDs.battery, UUIDs.deviceInformation, UUIDs.vendor])
    }

    public func centralManager(_ central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error: Error?) {
        guard peripheral.identifier == self.peripheral?.identifier else { return }
        self.peripheral = nil
        info = nil
    }
}

extension BluetoothKeyboardMonitor: @preconcurrency CBPeripheralDelegate {
    public func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
        let services = peripheral.services ?? []
        info?.hasVendorService = services.contains { $0.uuid == UUIDs.vendor }
        for service in services where service.uuid != UUIDs.vendor {
            peripheral.discoverCharacteristics(nil, for: service)
        }
    }

    public func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
        for characteristic in service.characteristics ?? [] {
            switch characteristic.uuid {
            case UUIDs.batteryLevel:
                // Don't read: the firmware answers reads with a stale value. The first
                // notification arrives within ~5 s.
                peripheral.setNotifyValue(true, for: characteristic)
            case UUIDs.softwareRevision:
                peripheral.readValue(for: characteristic)
            default:
                break
            }
        }
    }

    public func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error: Error?) {
        guard error == nil, let value = characteristic.value else { return }
        switch characteristic.uuid {
        case UUIDs.batteryLevel:
            if let level = BluetoothKeyboardMonitor.parseBatteryLevel(value) {
                info?.batteryLevel = level
            }
        case UUIDs.softwareRevision:
            info?.softwareRevision = BluetoothKeyboardMonitor.parseString(value)
        default:
            break
        }
    }

    /// Battery Level is one unsigned byte, 0–100. Anything else is ignored.
    nonisolated static func parseBatteryLevel(_ data: Data) -> Int? {
        guard data.count == 1, let byte = data.first, byte <= 100 else { return nil }
        return Int(byte)
    }

    /// Trims NULs and whitespace and drops the SDK's placeholder strings.
    nonisolated static func parseString(_ data: Data) -> String? {
        guard let text = String(data: data, encoding: .utf8)?
            .trimmingCharacters(in: .whitespacesAndNewlines.union(CharacterSet(charactersIn: "\0"))),
            !text.isEmpty else { return nil }
        let placeholders: Set<String> = ["Firmware Revision", "Software Revision", "Hardware Revision", "Serial Number", "Model Number", "Manufacturer Name"]
        return placeholders.contains(text) ? nil : text
    }
}
