import Foundation
import IOKit.hid

public enum KeyboardDriverError: LocalizedError, Equatable {
    case notConnected
    case openFailed(Int32)
    case reportFailed(operation: String, status: Int32)
    /// The keyboard replied but didn't set the acknowledgement flag.
    case notAcknowledged(command: String)

    public var errorDescription: String? {
        switch self {
        case .notConnected:
            "The keyboard's USB-C command channel isn't available. Check the cable and that the keyboard is in wired mode."
        case .openFailed(let status):
            String(format: "Couldn't open the keyboard (IOReturn 0x%08X).", UInt32(bitPattern: status))
        case .reportFailed(let operation, let status):
            String(format: "%@ failed (IOReturn 0x%08X).", operation, UInt32(bitPattern: status))
        case .notAcknowledged(let command):
            "The keyboard didn't confirm the command (\(command))."
        }
    }
}

/// Talks to the F75 Max over USB-C on the 0xFF13 command channel.
///
/// An actor, so commands never interleave: a lighting sequence always runs start to finish
/// before the next begins. IOKit report calls are synchronous USB control transfers
/// (a few ms each) and run on the actor's executor, off the main thread.
public actor WiredKeyboardDriver {
    /// Wraps the CF handle so it can live inside the actor. Only the actor touches it.
    private final class DeviceHandle: @unchecked Sendable {
        let device: IOHIDDevice
        init(_ device: IOHIDDevice) { self.device = device }
    }

    private var handle: DeviceHandle?
    /// Pause before every SET_REPORT and before reading an acknowledgement.
    /// 35 ms is the delay the keyboard needs between commands.
    private let sendInterval: Duration
    /// Protocol research: read a reply after every packet, whatever the step says.
    private let alwaysExchange: Bool
    /// Protocol research: called with each packet sent (`sent == true`) and each reply.
    private let trace: (@Sendable (_ sent: Bool, _ bytes: [UInt8]) -> Void)?

    public init(
        sendInterval: Duration = .milliseconds(35),
        alwaysExchange: Bool = false,
        trace: (@Sendable (_ sent: Bool, _ bytes: [UInt8]) -> Void)? = nil
    ) {
        self.sendInterval = sendInterval
        self.alwaysExchange = alwaysExchange
        self.trace = trace
    }

    /// Whether a USB-C command channel is present right now. Needs no open and no permission.
    public static var isAvailable: Bool {
        findCommandDevice() != nil
    }

    public func syncClock(date: Date = Date(), twelveHour: Bool = false) async throws {
        try await run(AulaWiredProtocol.clockSync(date: date, twelveHour: twelveHour))
    }

    public func applyLighting(_ settings: LightingSettings) async throws {
        try await run(AulaWiredProtocol.lighting(settings))
    }

    public func applySettings(_ settings: KeyboardSettings) async throws {
        try await run(AulaWiredProtocol.settings(settings))
    }

    public struct UploadProgress: Sendable {
        public let sentChunks: Int
        public let totalChunks: Int
        public var fraction: Double { totalChunks == 0 ? 0 : Double(sentChunks) / Double(totalChunks) }
    }

    /// Uploads an encoded screen stream (see `DisplayEncoder.stream`). Returns how many chunks
    /// the keyboard acknowledged.
    @discardableResult
    public func uploadDisplay(
        _ stream: Data,
        slot: UInt8 = 1,
        progress: @Sendable (UploadProgress) -> Void = { _ in }
    ) async throws -> Int {
        precondition(stream.count % DisplayEncoder.chunkLength == 0, "stream must be padded to 4096-byte chunks")
        let chunkCount = stream.count / DisplayEncoder.chunkLength
        guard chunkCount > 0, chunkCount <= 0xFFFF else { throw KeyboardDriverError.notConnected }

        guard let raw = Self.findDevice(usagePage: AulaDeviceIdentifiers.UsagePage.wiredDisplay) else {
            throw KeyboardDriverError.notConnected
        }
        let status = IOHIDDeviceOpen(raw, IOOptionBits(kIOHIDOptionsTypeNone))
        guard status == kIOReturnSuccess else { throw KeyboardDriverError.openFailed(status) }
        let acks = InputReportCounter(device: raw)
        defer {
            acks.close()
            IOHIDDeviceClose(raw, IOOptionBits(kIOHIDOptionsTypeNone))
        }

        try await run(AulaWiredProtocol.displayUploadBegin(slot: slot, chunkCount: chunkCount))
        _ = await acks.waitForNext(after: acks.count, timeout: .milliseconds(150))

        var acknowledged = 0
        let bytes = [UInt8](stream)
        for index in 0..<chunkCount {
            let chunk = Array(bytes[(index * DisplayEncoder.chunkLength)..<((index + 1) * DisplayEncoder.chunkLength)])
            let before = acks.count
            do {
                try setReport(raw, kIOHIDReportTypeOutput, chunk)
            } catch {
                close()
                throw error
            }
            if await acks.waitForNext(after: before, timeout: .milliseconds(400)) {
                acknowledged += 1
            }
            progress(UploadProgress(sentChunks: index + 1, totalChunks: chunkCount))
        }

        try await run(AulaWiredProtocol.displayUploadFinish)
        return acknowledged
    }

    /// Protocol research only: sends an arbitrary sequence. Feature code uses typed commands.
    public func send(_ steps: [AulaWiredProtocol.Step]) async throws {
        try await run(steps)
    }

    public func close() {
        if let handle {
            IOHIDDeviceClose(handle.device, IOOptionBits(kIOHIDOptionsTypeNone))
        }
        handle = nil
    }

    // MARK: - Transport

    private func run(_ steps: [AulaWiredProtocol.Step]) async throws {
        let device = try openDevice()
        do {
            // The keyboard needs a short pause before every SET_REPORT and before reading an acknowledgement.
            for step in steps {
                try await Task.sleep(for: sendInterval)
                trace?(true, step.bytes)
                switch step.kind {
                case .output:
                    try setReport(device, kIOHIDReportTypeOutput, step.bytes)
                case .exchange:
                    try setReport(device, kIOHIDReportTypeFeature, step.bytes)
                    trace?(false, try getFeature(device))
                case .sendThenReadEcho:
                    try setReport(device, kIOHIDReportTypeFeature, step.bytes)
                    try await Task.sleep(for: sendInterval)
                    trace?(false, try getFeature(device))
                case .sendThenRead:
                    try setReport(device, kIOHIDReportTypeFeature, step.bytes)
                    try await Task.sleep(for: sendInterval)
                    let reply = try getFeature(device)
                    trace?(false, reply)
                    guard AulaWiredProtocol.isAcknowledged(reply) else {
                        throw KeyboardDriverError.notAcknowledged(
                            command: step.bytes.prefix(2).map { String(format: "%02X", $0) }.joined(separator: " ")
                        )
                    }
                case .send:
                    try setReport(device, kIOHIDReportTypeFeature, step.bytes)
                    if alwaysExchange {
                        trace?(false, try getFeature(device))
                    }
                }
            }
        } catch {
            // The device may have been unplugged. Reopen on the next command.
            close()
            throw error
        }
    }

    private func openDevice() throws -> IOHIDDevice {
        if let handle { return handle.device }
        guard let device = Self.findCommandDevice() else { throw KeyboardDriverError.notConnected }
        let status = IOHIDDeviceOpen(device, IOOptionBits(kIOHIDOptionsTypeNone))
        guard status == kIOReturnSuccess else { throw KeyboardDriverError.openFailed(status) }
        handle = DeviceHandle(device)
        return device
    }

    private func setReport(_ device: IOHIDDevice, _ type: IOHIDReportType, _ bytes: [UInt8]) throws {
        let status = bytes.withUnsafeBufferPointer {
            IOHIDDeviceSetReport(device, type, 0, $0.baseAddress!, $0.count)
        }
        guard status == kIOReturnSuccess else {
            let name = type == kIOHIDReportTypeOutput ? "SET_REPORT (output)" : "SET_REPORT"
            throw KeyboardDriverError.reportFailed(operation: name, status: status)
        }
    }

    private func getFeature(_ device: IOHIDDevice) throws -> [UInt8] {
        var buffer = [UInt8](repeating: 0, count: AulaWiredProtocol.packetLength)
        var length = buffer.count
        let status = buffer.withUnsafeMutableBufferPointer {
            IOHIDDeviceGetReport(device, kIOHIDReportTypeFeature, 0, $0.baseAddress!, &length)
        }
        guard status == kIOReturnSuccess else {
            throw KeyboardDriverError.reportFailed(operation: "GET_REPORT", status: status)
        }
        return Array(buffer.prefix(length))
    }

    private static func findCommandDevice() -> IOHIDDevice? {
        findDevice(usagePage: AulaDeviceIdentifiers.UsagePage.wiredCommand)
            .flatMap { $0.intProperty(kIOHIDMaxFeatureReportSizeKey) >= AulaWiredProtocol.packetLength ? $0 : nil }
    }

    private static func findDevice(usagePage: Int) -> IOHIDDevice? {
        let manager = IOHIDManagerCreate(kCFAllocatorDefault, IOOptionBits(kIOHIDOptionsTypeNone))
        IOHIDManagerSetDeviceMatching(manager, [
            kIOHIDVendorIDKey: AulaDeviceIdentifiers.wiredVendorID,
            kIOHIDProductIDKey: AulaDeviceIdentifiers.wiredProductID,
            kIOHIDPrimaryUsagePageKey: usagePage,
        ] as NSDictionary)
        guard let devices = IOHIDManagerCopyDevices(manager) as? Set<IOHIDDevice> else { return nil }
        return devices.first
    }
}

/// Counts input reports from a device, delivered on a private dispatch queue.
/// The display interface sends one short report to acknowledge each chunk.
private final class InputReportCounter: @unchecked Sendable {
    private let device: IOHIDDevice
    private let queue = DispatchQueue(label: "aula.display.input")
    private let lock = NSLock()
    private var received = 0
    private let buffer: UnsafeMutablePointer<UInt8>
    private let bufferLength = 512
    private let cancelled = DispatchSemaphore(value: 0)

    init(device: IOHIDDevice) {
        self.device = device
        buffer = .allocate(capacity: bufferLength)
        let context = Unmanaged.passUnretained(self).toOpaque()
        IOHIDDeviceRegisterInputReportCallback(device, buffer, bufferLength, { context, result, _, _, _, _, length in
            guard let context, result == kIOReturnSuccess, length > 0 else { return }
            Unmanaged<InputReportCounter>.fromOpaque(context).takeUnretainedValue().increment()
        }, context)
        IOHIDDeviceSetDispatchQueue(device, queue)
        IOHIDDeviceSetCancelHandler(device) { [cancelled] in cancelled.signal() }
        IOHIDDeviceActivate(device)
    }

    var count: Int {
        lock.lock(); defer { lock.unlock() }
        return received
    }

    private func increment() {
        lock.lock(); received += 1; lock.unlock()
    }

    /// Waits until more than `baseline` reports have arrived, or until the timeout.
    func waitForNext(after baseline: Int, timeout: Duration) async -> Bool {
        let deadline = ContinuousClock.now + timeout
        while ContinuousClock.now < deadline {
            if count > baseline { return true }
            try? await Task.sleep(for: .milliseconds(2))
        }
        return count > baseline
    }

    func close() {
        IOHIDDeviceCancel(device)
        // No callback may still be running when the buffer is freed.
        _ = cancelled.wait(timeout: .now() + 1)
        buffer.deallocate()
    }
}
