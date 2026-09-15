import Foundation
import IOKit.hid

public struct KeyEvent: Hashable, Sendable {
    public let usage: HIDUsage
    public let isDown: Bool
    public let timestamp: UInt64

    public init(usage: HIDUsage, isDown: Bool, timestamp: UInt64 = mach_absolute_time()) {
        self.usage = usage
        self.isDown = isDown
        self.timestamp = timestamp
    }
}

public enum InputMonitoringAccess: Sendable, Equatable {
    case granted
    case denied
    case notDetermined

    public static var current: InputMonitoringAccess {
        switch IOHIDCheckAccess(kIOHIDRequestTypeListenEvent) {
        case kIOHIDAccessTypeGranted: .granted
        case kIOHIDAccessTypeDenied: .denied
        default: .notDetermined
        }
    }

    /// Shows the system prompt the first time. After that the user has to change it in System Settings.
    @discardableResult
    public static func request() -> InputMonitoringAccess {
        _ = IOHIDRequestAccess(kIOHIDRequestTypeListenEvent)
        return current
    }

    public static let settingsURL = URL(
        string: "x-apple.systempreferences:com.apple.preference.security?Privacy_ListenEvent"
    )!
}

@MainActor
public protocol KeyEventSource: AnyObject {
    var onEvent: (@MainActor (KeyEvent) -> Void)? { get set }
    /// Starts listening if permission allows. Returns the resulting access state.
    @discardableResult func start() -> InputMonitoringAccess
    func stop()
}

/// Streams key-down and key-up events from the AULA keyboard (not other
/// keyboards) for live preview and the key tester. Opens devices without seizing
/// them, so typing keeps working normally. Needs Input Monitoring permission.
@MainActor
public final class KeyEventMonitor: KeyEventSource {
    public var onEvent: (@MainActor (KeyEvent) -> Void)?

    nonisolated(unsafe) private let manager: IOHIDManager
    private var isRunning = false

    public init(matches: [AulaDeviceIdentifiers.Match] = AulaDeviceIdentifiers.matches) {
        manager = IOHIDManagerCreate(kCFAllocatorDefault, IOOptionBits(kIOHIDOptionsTypeNone))
        let dictionaries = matches.flatMap { match in
            // Only the standard keyboard and consumer collections. Vendor pages are left alone.
            [(0x01, 0x06), (0x0C, 0x01)].map { page, usage in
                [
                    kIOHIDVendorIDKey: match.vendorID,
                    kIOHIDProductIDKey: match.productID,
                    kIOHIDDeviceUsagePageKey: page,
                    kIOHIDDeviceUsageKey: usage,
                ] as NSDictionary
            }
        }
        IOHIDManagerSetDeviceMatchingMultiple(manager, dictionaries as CFArray)
    }

    deinit {
        IOHIDManagerUnscheduleFromRunLoop(manager, CFRunLoopGetMain(), CFRunLoopMode.defaultMode.rawValue)
        IOHIDManagerClose(manager, IOOptionBits(kIOHIDOptionsTypeNone))
    }

    @discardableResult
    public func start() -> InputMonitoringAccess {
        let access = InputMonitoringAccess.current
        guard access == .granted, !isRunning else { return access }

        let context = Unmanaged.passUnretained(self).toOpaque()
        IOHIDManagerRegisterInputValueCallback(manager, { context, result, _, value in
            guard let context, result == kIOReturnSuccess else { return }
            let element = IOHIDValueGetElement(value)
            let page = IOHIDElementGetUsagePage(element)
            let id = IOHIDElementGetUsage(element)
            guard KeyEventMonitor.isInteresting(page: page, usage: id) else { return }
            let event = KeyEvent(
                usage: HIDUsage(page: page, id: id),
                isDown: IOHIDValueGetIntegerValue(value) != 0,
                timestamp: IOHIDValueGetTimeStamp(value)
            )
            MainActor.assumeIsolated {
                Unmanaged<KeyEventMonitor>.fromOpaque(context).takeUnretainedValue().onEvent?(event)
            }
        }, context)

        IOHIDManagerScheduleWithRunLoop(manager, CFRunLoopGetMain(), CFRunLoopMode.defaultMode.rawValue)
        let status = IOHIDManagerOpen(manager, IOOptionBits(kIOHIDOptionsTypeNone))
        guard status == kIOReturnSuccess else {
            IOHIDManagerUnscheduleFromRunLoop(manager, CFRunLoopGetMain(), CFRunLoopMode.defaultMode.rawValue)
            return status == kIOReturnNotPermitted ? .denied : access
        }
        isRunning = true
        return .granted
    }

    public func stop() {
        guard isRunning else { return }
        isRunning = false
        IOHIDManagerRegisterInputValueCallback(manager, nil, nil)
        IOHIDManagerUnscheduleFromRunLoop(manager, CFRunLoopGetMain(), CFRunLoopMode.defaultMode.rawValue)
        IOHIDManagerClose(manager, IOOptionBits(kIOHIDOptionsTypeNone))
    }

    nonisolated static func isInteresting(page: UInt32, usage: UInt32) -> Bool {
        switch page {
        // 0x04...0xE7 skips the error/rollover codes (0x00...0x03) and reserved space.
        case HIDUsage.Page.keyboard: (0x04...0xE7).contains(usage)
        case HIDUsage.Page.consumer: usage != 0
        default: false
        }
    }
}
