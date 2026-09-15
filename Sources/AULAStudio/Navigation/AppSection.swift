import Observation
import SwiftUI

enum AppSection: String, CaseIterable, Identifiable, Hashable {
    case dashboard, lighting, display, keymap, macros, profiles, firmware, settings

    var id: String { rawValue }

    var title: String {
        switch self {
        case .dashboard: "Dashboard"
        case .lighting: "Lighting"
        case .display: "Display"
        case .keymap: "Keymap"
        case .macros: "Macros"
        case .profiles: "Profiles"
        case .firmware: "Firmware"
        case .settings: "Settings"
        }
    }

    var symbol: String {
        switch self {
        case .dashboard: "square.grid.2x2"
        case .lighting: "light.max"
        case .display: "photo.on.rectangle"
        case .keymap: "keyboard"
        case .macros: "record.circle"
        case .profiles: "person.crop.rectangle.stack"
        case .firmware: "cpu"
        case .settings: "gearshape"
        }
    }

    /// ⌘1 through ⌘8
    var shortcut: KeyEquivalent {
        KeyEquivalent(Character(String((AppSection.allCases.firstIndex(of: self) ?? 0) + 1)))
    }
}

/// Navigation state shared by the sidebar, the command palette and menu commands.
@MainActor
@Observable
final class AppRouter {
    var section: AppSection = .dashboard
    var isCommandPaletteOpen = false
    var selectedKeyIDs: Set<String> = []
    var showsKeyTester = false
    /// Notices the user closed. Kept in memory only, so they show again next launch.
    var dismissedNotices: Set<String> = []
}
