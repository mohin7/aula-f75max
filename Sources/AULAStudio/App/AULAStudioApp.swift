import AppKit
import AulaDesignSystem
import SwiftUI

@main
struct AULAStudioApp: App {
    static let mainWindowID = "main"

    @NSApplicationDelegateAdaptor(AppDelegate.self) private var appDelegate
    @AppStorage(PreferenceKey.showMenuBarIcon) private var showMenuBarIcon = true
    @AppStorage(PreferenceKey.appearance) private var appearance = AppearancePreference.system.rawValue

    @State private var environment = AppEnvironment.live()

    var body: some Scene {
        Window("AULA Studio", id: Self.mainWindowID) {
            RootView()
                .inject(environment)
                .preferredColorScheme(colorScheme)
                .frame(minWidth: 980, minHeight: 640)
        }
        .defaultSize(width: 1280, height: 840)
        .windowToolbarStyle(.unified)
        .commands { AppCommands(router: environment.router) }

        Settings {
            SettingsView()
                .inject(environment)
                .preferredColorScheme(colorScheme)
                .frame(width: 720, height: 640)
        }

        MenuBarExtra("AULA Studio", systemImage: "keyboard", isInserted: $showMenuBarIcon) {
            MenuBarView()
                .inject(environment)
        }
        .menuBarExtraStyle(.window)
    }

    private var colorScheme: ColorScheme? {
        switch AppearancePreference(rawValue: appearance) ?? .system {
        case .system: nil
        case .light: .light
        case .dark: .dark
        }
    }
}

private extension View {
    func inject(_ environment: AppEnvironment) -> some View {
        self
            .environment(environment.store)
            .environment(environment.router)
            .environment(environment.toasts)
    }
}

private struct AppCommands: Commands {
    let router: AppRouter

    var body: some Commands {
        CommandGroup(after: .sidebar) {
            Button("Command Palette") { router.isCommandPaletteOpen.toggle() }
                .keyboardShortcut("k", modifiers: .command)
            Divider()
            ForEach(AppSection.allCases) { section in
                Button(section.title) { router.section = section }
                    .keyboardShortcut(section.shortcut, modifiers: .command)
            }
        }
    }
}

final class AppDelegate: NSObject, NSApplicationDelegate {
    func applicationDidFinishLaunching(_ notification: Notification) {
        // `swift run` launches a bare executable with no bundle. Make it a regular foreground app.
        if Bundle.main.bundleIdentifier == nil {
            NSApp.setActivationPolicy(.regular)
            NSApp.activate()
        }
    }
}
