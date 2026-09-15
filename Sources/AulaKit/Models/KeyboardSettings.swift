import Foundation

/// Keyboard-wide settings stored in firmware block 0x17.
///
/// The firmware can't report these back, so the app remembers the last values it sent.
public struct KeyboardSettings: Hashable, Codable, Sendable {
    public enum SleepTime: Int, CaseIterable, Codable, Sendable, Identifiable {
        case never = 0
        case oneMinute = 1
        case fiveMinutes = 2
        case thirtyMinutes = 3

        public var id: Int { rawValue }

        public var title: String {
            switch self {
            case .never: "Never"
            case .oneMinute: "1 min"
            case .fiveMinutes: "5 min"
            case .thirtyMinutes: "30 min"
            }
        }
    }

    public static let responseLevels = 1...5

    /// 1 (fastest) to 5 (most debounce).
    public var responseLevel: Int {
        didSet { responseLevel = responseLevel.clamped(to: Self.responseLevels) }
    }
    public var sleepTime: SleepTime
    public var disableWindowsKey: Bool
    public var disableAltF4: Bool
    public var disableAltTab: Bool
    /// Swaps the top row between F-keys and media keys.
    public var fnSwitch: Bool

    /// Firmware factory defaults.
    public init(
        responseLevel: Int = 2,
        sleepTime: SleepTime = .fiveMinutes,
        disableWindowsKey: Bool = false,
        disableAltF4: Bool = false,
        disableAltTab: Bool = false,
        fnSwitch: Bool = false
    ) {
        self.responseLevel = responseLevel.clamped(to: Self.responseLevels)
        self.sleepTime = sleepTime
        self.disableWindowsKey = disableWindowsKey
        self.disableAltF4 = disableAltF4
        self.disableAltTab = disableAltTab
        self.fnSwitch = fnSwitch
    }

    /// Typical latency for each response level, from AULA's published figures.
    public static func latencyDescription(level: Int) -> String {
        switch level {
        case 1: "Wired 2–3 ms · 2.4G 5–6 ms · Bluetooth 12–13 ms"
        case 2: "Wired 5–6 ms · 2.4G 7–9 ms · Bluetooth 15–16 ms"
        case 3: "Wired 8–9 ms · 2.4G 10–12 ms · Bluetooth 18–19 ms"
        case 4: "Wired 13–14 ms · 2.4G 15–17 ms · Bluetooth 23–24 ms"
        default: "Wired 17–18 ms · 2.4G 19–21 ms · Bluetooth 27–28 ms"
        }
    }
}
