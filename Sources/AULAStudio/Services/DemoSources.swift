import AulaKit
import Foundation

/// Pretends a wired F75 Max is connected, for UI work without hardware.
/// Turn it on in Settings → Developer, or launch with `AULA_DEMO=1`.
@MainActor
final class DemoDeviceDiscovery: DeviceDiscovering {
    var onChange: (@MainActor ([HIDEndpoint]) -> Void)?

    func start() {
        typealias IDs = AulaDeviceIdentifiers
        func endpoint(_ id: UInt64, page: Int, usage: Int, input: Int, output: Int, feature: Int) -> HIDEndpoint {
            HIDEndpoint(
                id: id, vendorID: IDs.wiredVendorID, productID: IDs.wiredProductID,
                usagePage: page, usage: usage, product: "AULA F75 Max (Demo)", manufacturer: "Demo",
                transport: "USB", locationID: 0x0100_0000, versionNumber: 0x0138,
                maxInputReportSize: input, maxOutputReportSize: output, maxFeatureReportSize: feature
            )
        }
        onChange?([
            endpoint(1, page: 0x01, usage: 0x06, input: 8, output: 1, feature: 0),
            endpoint(2, page: 0x0C, usage: 0x01, input: 3, output: 0, feature: 0),
            endpoint(3, page: IDs.UsagePage.wiredCommand, usage: 0x61, input: 0, output: 0, feature: 64),
            endpoint(4, page: IDs.UsagePage.wiredDisplay, usage: 0x61, input: 128, output: 4096, feature: 0),
        ])
    }

    func stop() {
        onChange?([])
    }
}

/// Types a demo phrase on a loop and turns the knob now and then.
@MainActor
final class DemoKeyEventSource: KeyEventSource {
    var onEvent: (@MainActor (KeyEvent) -> Void)?
    private var task: Task<Void, Never>?

    private static let phrase: [UInt32] = {
        let text = "hello aula studio "
        return text.compactMap { character -> UInt32? in
            if character == " " { return 0x2C }
            guard let ascii = character.asciiValue, (97...122).contains(ascii) else { return nil }
            return 0x04 + UInt32(ascii - 97)
        }
    }()

    @discardableResult
    func start() -> InputMonitoringAccess {
        task?.cancel()
        task = Task { [weak self] in
            var index = 0
            while !Task.isCancelled {
                let usage = HIDUsage.keyboard(Self.phrase[index % Self.phrase.count])
                self?.onEvent?(KeyEvent(usage: usage, isDown: true))
                try? await Task.sleep(for: .milliseconds(70))
                self?.onEvent?(KeyEvent(usage: usage, isDown: false))
                try? await Task.sleep(for: .milliseconds(Int.random(in: 60...220)))
                index += 1
                if index % 9 == 0 {
                    let knob = HIDUsage.consumer(Bool.random() ? 0xE9 : 0xEA)
                    self?.onEvent?(KeyEvent(usage: knob, isDown: true))
                    self?.onEvent?(KeyEvent(usage: knob, isDown: false))
                }
            }
        }
        return .granted
    }

    func stop() {
        task?.cancel()
        task = nil
    }
}
