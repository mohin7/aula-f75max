import Testing
@testable import AulaKit

@Suite("HID endpoint classification")
struct HIDEndpointTests {
    private func endpoint(
        vendor: Int = AulaDeviceIdentifiers.wirelessVendorID,
        product: Int = AulaDeviceIdentifiers.wirelessProductID,
        page: Int = 0x01,
        usage: Int = 0x06,
        name: String? = "AULA F75Max-1",
        transport: String? = "USB",
        id: UInt64 = 1,
        version: Int = 0
    ) -> HIDEndpoint {
        HIDEndpoint(
            id: id, vendorID: vendor, productID: product, usagePage: page, usage: usage,
            product: name, manufacturer: nil, transport: transport, locationID: 1, versionNumber: version,
            maxInputReportSize: 0, maxOutputReportSize: 0, maxFeatureReportSize: 0
        )
    }

    /// Matches what the IORegistry shows for a real F75 Max paired over BLE.
    @Test func realBluetoothKeyboardHasKeyEventsAndGATTBattery() throws {
        let ble = endpoint(transport: "Bluetooth Low Energy", version: 0x0138)
        #expect(ble.connectionKind == .bluetooth)

        let keyboard = try #require(ConnectedKeyboard.group([ble]).first)
        #expect(keyboard.kind == .bluetooth)
        #expect(!keyboard.hasConfigurationChannel)
        #expect(keyboard.capabilities == [.keyEvents, .battery])
        #expect(!keyboard.capabilities.contains(.lighting))
        #expect(keyboard.hidVersion == "1.38")
    }

    @Test func wiredWithVendorChannelsExposesConfiguration() throws {
        typealias IDs = AulaDeviceIdentifiers
        let endpoints = [
            endpoint(vendor: IDs.wiredVendorID, product: IDs.wiredProductID, id: 1),
            endpoint(vendor: IDs.wiredVendorID, product: IDs.wiredProductID, page: IDs.UsagePage.wiredCommand, usage: 0x61, id: 2),
            endpoint(vendor: IDs.wiredVendorID, product: IDs.wiredProductID, page: IDs.UsagePage.wiredDisplay, usage: 0x61, id: 3),
        ]
        let keyboard = try #require(ConnectedKeyboard.group(endpoints).first)
        #expect(keyboard.kind == .wired)
        #expect(keyboard.hasConfigurationChannel)
        #expect(keyboard.capabilities.contains([.lighting, .display]))
        #expect(endpoints[1].role == .command)
        #expect(endpoints[2].role == .display)
    }

    @Test func dongleRoles() {
        let raw = endpoint(page: AulaDeviceIdentifiers.UsagePage.dongleRaw, usage: 0x61)
        #expect(raw.connectionKind == .dongle)
        #expect(raw.role == .raw)
        #expect(raw.role.isConfigurationChannel)
    }

    @Test func linksWithoutVendorChannelsAreCappedToKeyEvents() throws {
        let keyboard = try #require(ConnectedKeyboard.group([endpoint(transport: "USB")]).first)
        #expect(keyboard.kind == .dongle)
        #expect(keyboard.capabilities == .keyEvents)
    }

    @Test func appleDevicesSharingTheVendorIDAreIgnored() {
        #expect(endpoint(name: "Apple Keyboard", transport: "USB").connectionKind == nil)
        #expect(endpoint(vendor: 0x046D, product: 0xB034).connectionKind == nil)
    }

    @Test func mostCapableLinkComesFirst() {
        let ble = endpoint(transport: "Bluetooth Low Energy", id: 1)
        let wired = endpoint(vendor: AulaDeviceIdentifiers.wiredVendorID, product: AulaDeviceIdentifiers.wiredProductID, id: 2)
        #expect(ConnectedKeyboard.group([ble, wired]).map(\.kind) == [.wired, .bluetooth])
    }

    @Test func keyEventFilter() {
        #expect(KeyEventMonitor.isInteresting(page: 0x07, usage: 0x04))
        #expect(!KeyEventMonitor.isInteresting(page: 0x07, usage: 0x01)) // rollover error
        #expect(!KeyEventMonitor.isInteresting(page: 0x07, usage: 0xFFFF_FFFF))
        #expect(KeyEventMonitor.isInteresting(page: 0x0C, usage: 0xE9))
        #expect(!KeyEventMonitor.isInteresting(page: 0x01, usage: 0x30))
    }

    @Test func usageNames() {
        #expect(HIDUsage.keyboard(0x04).name == "A")
        #expect(HIDUsage.keyboard(0x27).name == "0")
        #expect(HIDUsage.keyboard(0x45).name == "F12")
        #expect(HIDUsage.consumer(0xE9).name == "Volume Up")
        #expect(HIDUsage.keyboard(0xE0).isModifier)
    }
}
