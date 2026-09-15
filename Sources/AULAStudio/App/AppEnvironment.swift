import AulaDesignSystem
import Foundation

/// Composition root. Every service is built here and injected through the
/// SwiftUI environment. Views never create services themselves.
@MainActor
final class AppEnvironment {
    let store: KeyboardStore
    let router = AppRouter()
    let toasts = ToastCenter()

    init(store: KeyboardStore) {
        self.store = store
    }

    static func live() -> AppEnvironment {
        let demo = ProcessInfo.processInfo.environment["AULA_DEMO"] == "1"
            || UserDefaults.standard.bool(forKey: PreferenceKey.demoMode)
        let environment = AppEnvironment(store: KeyboardStore(demo: demo))
        environment.store.start()
        return environment
    }
}

enum PreferenceKey {
    static let appearance = "appearance"
    static let accentFollowsLighting = "accentFollowsLighting"
    static let showMenuBarIcon = "showMenuBarIcon"
    static let demoMode = "demoMode"
    static let timeFormat = "timeFormat"
}

enum TimeFormatPreference: String, CaseIterable, Identifiable {
    case system, twelveHour, twentyFourHour

    var id: String { rawValue }

    var title: String {
        switch self {
        case .system: "System"
        case .twelveHour: "12-hour"
        case .twentyFourHour: "24-hour"
        }
    }

    func string(from date: Date) -> String {
        switch self {
        case .system:
            return date.formatted(date: .omitted, time: .shortened)
        case .twelveHour:
            let formatter = DateFormatter()
            formatter.dateFormat = "h:mm a"
            return formatter.string(from: date)
        case .twentyFourHour:
            let formatter = DateFormatter()
            formatter.dateFormat = "HH:mm"
            return formatter.string(from: date)
        }
    }
}

enum AppearancePreference: String, CaseIterable, Identifiable {
    case system, light, dark

    var id: String { rawValue }
    var title: String { rawValue.capitalized }
}
