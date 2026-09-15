import Foundation

/// USB/Bluetooth identifiers for the F75 Max.
///
/// Where these come from:
/// - Bluetooth LE (0x05AC:0x024F, product "AULA F75Max-1"): seen directly in the
///   IORegistry on a real keyboard. Over BLE it shows only standard keyboard,
///   consumer, mouse and dial reports. There's no vendor configuration channel.
/// - Wired (0x0C45:0x800A) and 2.4G receiver (0x05AC:0x024F) plus the vendor usage
///   pages come from community reverse-engineering (MIT-licensed
///   VitalyArt/Aula-F75-Max-Driver). See `Docs/Hardware-Protocol-Notes.md`.
public enum AulaDeviceIdentifiers {
    public static let wiredVendorID = 0x0C45
    public static let wiredProductID = 0x800A

    /// The receiver and the BLE keyboard both report Apple's vendor ID with this product ID.
    public static let wirelessVendorID = 0x05AC
    public static let wirelessProductID = 0x024F

    public enum UsagePage {
        /// Wired: 64-byte feature-report command channel.
        public static let wiredCommand = 0xFF13
        /// Wired: 4096-byte output reports for display image streams.
        public static let wiredDisplay = 0xFF68
        /// 2.4G receiver: command channel.
        public static let dongleCommand = 0xFF59
        /// 2.4G receiver: 32-byte output reports (RGB, performance, battery).
        public static let dongleRaw = 0xFF60
    }

    public struct Match: Hashable, Sendable {
        public let vendorID: Int
        public let productID: Int
    }

    public static let matches: [Match] = [
        Match(vendorID: wiredVendorID, productID: wiredProductID),
        Match(vendorID: wirelessVendorID, productID: wirelessProductID),
    ]
}
