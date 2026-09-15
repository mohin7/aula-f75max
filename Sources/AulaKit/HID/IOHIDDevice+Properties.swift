import Foundation
import IOKit.hid

extension IOHIDDevice {
    func intProperty(_ key: String) -> Int {
        guard let value = IOHIDDeviceGetProperty(self, key as CFString) else { return 0 }
        return (value as? NSNumber)?.intValue ?? 0
    }

    func stringProperty(_ key: String) -> String? {
        IOHIDDeviceGetProperty(self, key as CFString) as? String
    }

    var registryEntryID: UInt64 {
        var id: UInt64 = 0
        IORegistryEntryGetRegistryEntryID(IOHIDDeviceGetService(self), &id)
        return id
    }

    var endpoint: HIDEndpoint {
        let primaryPage = intProperty(kIOHIDPrimaryUsagePageKey)
        let primaryUsage = intProperty(kIOHIDPrimaryUsageKey)
        return HIDEndpoint(
            id: registryEntryID,
            vendorID: intProperty(kIOHIDVendorIDKey),
            productID: intProperty(kIOHIDProductIDKey),
            usagePage: primaryPage != 0 ? primaryPage : intProperty(kIOHIDDeviceUsagePageKey),
            usage: primaryUsage != 0 ? primaryUsage : intProperty(kIOHIDDeviceUsageKey),
            product: stringProperty(kIOHIDProductKey),
            manufacturer: stringProperty(kIOHIDManufacturerKey),
            transport: stringProperty(kIOHIDTransportKey),
            locationID: intProperty(kIOHIDLocationIDKey),
            versionNumber: intProperty(kIOHIDVersionNumberKey),
            maxInputReportSize: intProperty(kIOHIDMaxInputReportSizeKey),
            maxOutputReportSize: intProperty(kIOHIDMaxOutputReportSizeKey),
            maxFeatureReportSize: intProperty(kIOHIDMaxFeatureReportSizeKey)
        )
    }
}

enum HIDMatching {
    static func dictionaries(for matches: [AulaDeviceIdentifiers.Match]) -> CFArray {
        matches.map {
            [kIOHIDVendorIDKey: $0.vendorID, kIOHIDProductIDKey: $0.productID] as NSDictionary
        } as CFArray
    }
}
