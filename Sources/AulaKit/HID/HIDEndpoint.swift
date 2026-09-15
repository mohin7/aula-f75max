import Foundation

/// A single IOHIDDevice interface (one top-level collection). One keyboard
/// shows up as several of these.
public struct HIDEndpoint: Identifiable, Hashable, Sendable {
    /// IORegistry entry ID. Stable while the device stays connected.
    public let id: UInt64
    public let vendorID: Int
    public let productID: Int
    public let usagePage: Int
    public let usage: Int
    public let product: String?
    public let manufacturer: String?
    public let transport: String?
    public let locationID: Int
    public let versionNumber: Int
    public let maxInputReportSize: Int
    public let maxOutputReportSize: Int
    public let maxFeatureReportSize: Int

    public init(
        id: UInt64,
        vendorID: Int,
        productID: Int,
        usagePage: Int,
        usage: Int,
        product: String?,
        manufacturer: String?,
        transport: String?,
        locationID: Int,
        versionNumber: Int,
        maxInputReportSize: Int,
        maxOutputReportSize: Int,
        maxFeatureReportSize: Int
    ) {
        self.id = id
        self.vendorID = vendorID
        self.productID = productID
        self.usagePage = usagePage
        self.usage = usage
        self.product = product
        self.manufacturer = manufacturer
        self.transport = transport
        self.locationID = locationID
        self.versionNumber = versionNumber
        self.maxInputReportSize = maxInputReportSize
        self.maxOutputReportSize = maxOutputReportSize
        self.maxFeatureReportSize = maxFeatureReportSize
    }

    public var connectionKind: ConnectionKind? {
        typealias IDs = AulaDeviceIdentifiers
        let isBluetooth = transport?.localizedCaseInsensitiveContains("bluetooth") == true
        switch (vendorID, productID) {
        case (IDs.wiredVendorID, IDs.wiredProductID):
            return .wired
        case (IDs.wirelessVendorID, IDs.wirelessProductID):
            if isBluetooth { return .bluetooth }
            // Apple's vendor ID is shared, so don't claim Apple-branded USB devices.
            if let product, product.localizedCaseInsensitiveContains("apple") { return nil }
            return .dongle
        default:
            return nil
        }
    }

    public var role: Role {
        typealias Page = AulaDeviceIdentifiers.UsagePage
        switch usagePage {
        case Page.wiredCommand, Page.dongleCommand: return .command
        case Page.wiredDisplay: return .display
        case Page.dongleRaw: return .raw
        case 0x01 where usage == 0x06: return .keyboard
        case 0x01 where usage == 0x02: return .mouse
        case 0x01 where usage == 0x80: return .systemControl
        case 0x0C: return .consumer
        case 0xFF00...0xFFFF: return .vendor
        default: return .other
        }
    }

    public enum Role: String, Sendable {
        case keyboard = "Keyboard"
        case consumer = "Media / Knob"
        case mouse = "Mouse"
        case systemControl = "System Control"
        case command = "Vendor Command"
        case raw = "Vendor Raw"
        case display = "Display Stream"
        case vendor = "Vendor"
        case other = "Other"

        public var isConfigurationChannel: Bool {
            self == .command || self == .raw || self == .display
        }
    }
}

public enum ConnectionKind: String, Codable, Sendable, CaseIterable {
    case wired
    case dongle
    case bluetooth

    public var title: String {
        switch self {
        case .wired: "USB-C"
        case .dongle: "2.4G Receiver"
        case .bluetooth: "Bluetooth"
        }
    }

    public var symbolName: String {
        switch self {
        case .wired: "cable.connector"
        case .dongle: "antenna.radiowaves.left.and.right"
        case .bluetooth: "dot.radiowaves.right"
        }
    }

    /// Manufacturer-rated polling rate for this link.
    public var ratedPollingRate: String {
        switch self {
        case .wired, .dongle: "1000 Hz"
        case .bluetooth: "BLE interval"
        }
    }

    /// What each link can do, based on known vendor endpoints. Firmware may
    /// surprise us, so the store also checks which endpoints are actually present.
    public var capabilities: DeviceCapabilities {
        switch self {
        case .wired: [.keyEvents, .lighting, .display, .clockSync, .keymap, .factoryReset]
        case .dongle: [.keyEvents, .lighting, .battery, .performance, .gameMode]
        // Battery comes from the standard GATT Battery Service, not HID.
        case .bluetooth: [.keyEvents, .battery]
        }
    }
}

public struct DeviceCapabilities: OptionSet, Hashable, Sendable {
    public let rawValue: Int
    public init(rawValue: Int) { self.rawValue = rawValue }

    public static let keyEvents = DeviceCapabilities(rawValue: 1 << 0)
    public static let lighting = DeviceCapabilities(rawValue: 1 << 1)
    public static let display = DeviceCapabilities(rawValue: 1 << 2)
    public static let battery = DeviceCapabilities(rawValue: 1 << 3)
    public static let performance = DeviceCapabilities(rawValue: 1 << 4)
    public static let gameMode = DeviceCapabilities(rawValue: 1 << 5)
    public static let clockSync = DeviceCapabilities(rawValue: 1 << 6)
    public static let keymap = DeviceCapabilities(rawValue: 1 << 7)
    public static let factoryReset = DeviceCapabilities(rawValue: 1 << 8)
    public static let firmwareUpdate = DeviceCapabilities(rawValue: 1 << 9)

    public static let all: [(DeviceCapabilities, String)] = [
        (.keyEvents, "Live key events"),
        (.lighting, "Lighting"),
        (.display, "Display upload"),
        (.battery, "Battery level"),
        (.performance, "Response & sleep"),
        (.gameMode, "Game Mode"),
        (.clockSync, "Clock sync"),
        (.keymap, "Keymap"),
        (.factoryReset, "Factory reset"),
        (.firmwareUpdate, "Firmware update"),
    ]
}

/// One physical keyboard, grouped from its endpoints.
public struct ConnectedKeyboard: Identifiable, Hashable, Sendable {
    public let kind: ConnectionKind
    public let endpoints: [HIDEndpoint]

    public init(kind: ConnectionKind, endpoints: [HIDEndpoint]) {
        self.kind = kind
        self.endpoints = endpoints
    }

    public var id: String { "\(kind.rawValue)-\(endpoints.map(\.locationID).min() ?? 0)" }

    public var productName: String {
        endpoints.lazy.compactMap(\.product).first { !$0.isEmpty } ?? "AULA F75 Max"
    }

    /// bcdDevice, e.g. 0x0138 → "1.38". Tells you the firmware build, not the marketing version.
    public var hidVersion: String? {
        guard let raw = endpoints.map(\.versionNumber).max(), raw > 0 else { return nil }
        return String(format: "%X.%02X", raw >> 8, raw & 0xFF)
    }

    public var hasConfigurationChannel: Bool {
        endpoints.contains { $0.role.isConfigurationChannel }
    }

    public var capabilities: DeviceCapabilities {
        let caps = kind.capabilities
        // USB links need their vendor HID endpoints. Bluetooth features don't go through HID.
        guard kind != .bluetooth, !hasConfigurationChannel else { return caps }
        return caps.intersection(.keyEvents)
    }

    /// Groups endpoints by connection kind. Kinds are ordered by capability
    /// (wired > dongle > bluetooth), so the best link comes first.
    public static func group(_ endpoints: [HIDEndpoint]) -> [ConnectedKeyboard] {
        let grouped = Dictionary(grouping: endpoints.filter { $0.connectionKind != nil }) { $0.connectionKind! }
        return ConnectionKind.allCases.compactMap { kind in
            guard let items = grouped[kind], !items.isEmpty else { return nil }
            return ConnectedKeyboard(
                kind: kind,
                endpoints: items.sorted { ($0.usagePage, $0.usage) < ($1.usagePage, $1.usage) }
            )
        }
    }
}
