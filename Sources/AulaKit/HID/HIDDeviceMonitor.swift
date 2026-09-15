import Foundation
import IOKit.hid

/// Reports AULA HID endpoints as they connect and disconnect.
@MainActor
public protocol DeviceDiscovering: AnyObject {
    var onChange: (@MainActor ([HIDEndpoint]) -> Void)? { get set }
    func start()
    func stop()
}

/// IOHIDManager-based discovery. Only enumerates. It never opens devices, so it
/// needs no Input Monitoring permission and can't disturb normal typing.
@MainActor
public final class HIDDeviceMonitor: DeviceDiscovering {
    public var onChange: (@MainActor ([HIDEndpoint]) -> Void)?
    public private(set) var endpoints: [UInt64: HIDEndpoint] = [:]

    nonisolated(unsafe) private let manager: IOHIDManager
    private var handles: [ObjectIdentifier: UInt64] = [:]
    private var isRunning = false

    public init(matches: [AulaDeviceIdentifiers.Match] = AulaDeviceIdentifiers.matches) {
        manager = IOHIDManagerCreate(kCFAllocatorDefault, IOOptionBits(kIOHIDOptionsTypeNone))
        IOHIDManagerSetDeviceMatchingMultiple(manager, HIDMatching.dictionaries(for: matches))
    }

    deinit {
        IOHIDManagerUnscheduleFromRunLoop(manager, CFRunLoopGetMain(), CFRunLoopMode.defaultMode.rawValue)
    }

    public func start() {
        guard !isRunning else { return }
        isRunning = true
        let context = Unmanaged.passUnretained(self).toOpaque()

        IOHIDManagerRegisterDeviceMatchingCallback(manager, { context, _, _, device in
            guard let context else { return }
            let endpoint = device.endpoint
            let handle = ObjectIdentifier(device)
            MainActor.assumeIsolated {
                Unmanaged<HIDDeviceMonitor>.fromOpaque(context).takeUnretainedValue().insert(endpoint, handle: handle)
            }
        }, context)

        IOHIDManagerRegisterDeviceRemovalCallback(manager, { context, _, _, device in
            guard let context else { return }
            // The registry entry may already be gone, so look the device up by handle.
            let handle = ObjectIdentifier(device)
            MainActor.assumeIsolated {
                Unmanaged<HIDDeviceMonitor>.fromOpaque(context).takeUnretainedValue().remove(handle: handle)
            }
        }, context)

        // Callbacks fire on the main run loop, which is what makes `assumeIsolated` safe.
        IOHIDManagerScheduleWithRunLoop(manager, CFRunLoopGetMain(), CFRunLoopMode.defaultMode.rawValue)
    }

    public func stop() {
        guard isRunning else { return }
        isRunning = false
        IOHIDManagerRegisterDeviceMatchingCallback(manager, nil, nil)
        IOHIDManagerRegisterDeviceRemovalCallback(manager, nil, nil)
        IOHIDManagerUnscheduleFromRunLoop(manager, CFRunLoopGetMain(), CFRunLoopMode.defaultMode.rawValue)
        endpoints.removeAll()
        handles.removeAll()
        onChange?([])
    }

    /// One-shot snapshot, for the CLI and tests on real hardware.
    public nonisolated static func snapshot(
        matches: [AulaDeviceIdentifiers.Match] = AulaDeviceIdentifiers.matches
    ) -> [HIDEndpoint] {
        let manager = IOHIDManagerCreate(kCFAllocatorDefault, IOOptionBits(kIOHIDOptionsTypeNone))
        IOHIDManagerSetDeviceMatchingMultiple(manager, HIDMatching.dictionaries(for: matches))
        guard let set = IOHIDManagerCopyDevices(manager) as? Set<IOHIDDevice> else { return [] }
        return set.map(\.endpoint).sorted { ($0.locationID, $0.usagePage, $0.usage) < ($1.locationID, $1.usagePage, $1.usage) }
    }

    private func insert(_ endpoint: HIDEndpoint, handle: ObjectIdentifier) {
        handles[handle] = endpoint.id
        guard endpoints[endpoint.id] != endpoint else { return }
        endpoints[endpoint.id] = endpoint
        publish()
    }

    private func remove(handle: ObjectIdentifier) {
        guard let id = handles.removeValue(forKey: handle),
              endpoints.removeValue(forKey: id) != nil else { return }
        publish()
    }

    private func publish() {
        onChange?(Array(endpoints.values))
    }
}
