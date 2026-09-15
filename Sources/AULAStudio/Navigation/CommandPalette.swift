import AulaDesignSystem
import AulaKit
import SwiftUI

/// ⌘K: jump anywhere or run any action from the keyboard.
struct CommandPalette: View {
    @Environment(KeyboardStore.self) private var store
    @Environment(AppRouter.self) private var router
    @Environment(ToastCenter.self) private var toasts
    @AppStorage(PreferenceKey.appearance) private var appearance = AppearancePreference.system.rawValue

    @State private var query = ""
    @State private var highlighted = 0
    @FocusState private var isSearchFocused: Bool

    struct Command: Identifiable {
        let id: String
        let title: String
        let subtitle: String
        let symbol: String
        let perform: @MainActor () -> Void
    }

    private var commands: [Command] {
        var result: [Command] = AppSection.allCases.map { section in
            Command(id: "nav.\(section.id)", title: section.title, subtitle: "Go to · ⌘\(section.shortcut.character)", symbol: section.symbol) {
                router.section = section
            }
        }
        result += LightingMode.allCases.map { mode in
            Command(id: "light.\(mode.id)", title: "Lighting: \(mode.title)", subtitle: "Effect", symbol: mode.symbolName) {
                store.lighting.mode = mode
                toasts.show(Toast(.success, "Lighting set to \(mode.title)"))
            }
        }
        result += AppearancePreference.allCases.map { option in
            Command(id: "appearance.\(option.id)", title: "Appearance: \(option.title)", subtitle: "Theme", symbol: "circle.lefthalf.filled") {
                appearance = option.rawValue
            }
        }
        result += [
            Command(id: "tester", title: router.showsKeyTester ? "Hide Key Tester" : "Show Key Tester", subtitle: "Dashboard", symbol: "keyboard.badge.eye") {
                router.section = .dashboard
                router.showsKeyTester.toggle()
            },
            Command(id: "legends", title: "Legends: \(store.legendMode == .mac ? "Windows" : "Mac")", subtitle: "Keyboard", symbol: "command") {
                store.legendMode = store.legendMode == .mac ? .windows : .mac
            },
            Command(id: "input", title: "Allow Input Monitoring", subtitle: "Permissions", symbol: "hand.raised") {
                store.requestInputMonitoring()
            },
            Command(id: "diagnostics", title: "HID Diagnostics", subtitle: "Settings → Developer", symbol: "stethoscope") {
                router.section = .settings
            },
            Command(id: "clock", title: "Sync Keyboard Clock", subtitle: "USB-C", symbol: "clock.arrow.2.circlepath") {
                guard store.control.isAvailable else {
                    toasts.show(Toast(.warning, "Connect USB-C to sync the clock"))
                    return
                }
                Task {
                    await store.control.syncClock()
                    toasts.show(store.control.clockStatus == .done
                        ? Toast(.success, "Keyboard clock synced")
                        : Toast(.error, "Clock sync failed"))
                }
            },
            Command(id: "upload", title: "Upload Image to Screen", subtitle: "Display", symbol: "photo.on.rectangle") {
                router.section = .display
            },
            Command(id: "keyboardSettings", title: "Sleep Time & Key Response", subtitle: "Settings → Keyboard", symbol: "moon.zzz") {
                router.section = .settings
            },
        ]
        return result
    }

    private var filtered: [Command] {
        let terms = query.lowercased().split(separator: " ")
        guard !terms.isEmpty else { return Array(commands.prefix(12)) }
        return commands.filter { command in
            let haystack = "\(command.title) \(command.subtitle)".lowercased()
            return terms.allSatisfy { haystack.contains($0) }
        }
    }

    var body: some View {
        let results = filtered

        VStack(spacing: 0) {
            HStack(spacing: Spacing.sm) {
                Image(systemName: "magnifyingglass").foregroundStyle(Palette.textTertiary)
                TextField("Search commands, effects, sections…", text: $query)
                    .textFieldStyle(.plain)
                    .font(.system(size: 17))
                    .focused($isSearchFocused)
                    .onSubmit { run(results) }
                Text("esc")
                    .font(Typography.caption)
                    .foregroundStyle(Palette.textTertiary)
                    .padding(.horizontal, Spacing.xs)
                    .padding(.vertical, Spacing.xxxs)
                    .background(Palette.surfaceSunken, in: RoundedRectangle(cornerRadius: Radius.xs))
            }
            .padding(Spacing.md)

            Divider()

            ScrollViewReader { proxy in
                ScrollView {
                    VStack(spacing: Spacing.xxxs) {
                        if results.isEmpty {
                            Text("No matches").font(Typography.body).foregroundStyle(Palette.textTertiary).padding(Spacing.xl)
                        }
                        ForEach(Array(results.enumerated()), id: \.element.id) { index, command in
                            row(command, isHighlighted: index == highlighted)
                                .id(index)
                                .onTapGesture {
                                    highlighted = index
                                    run(results)
                                }
                        }
                    }
                    .padding(Spacing.xs)
                }
                .frame(maxHeight: 360)
                .onChange(of: highlighted) { _, index in proxy.scrollTo(index) }
            }
        }
        .frame(width: 560)
        .background(.regularMaterial, in: RoundedRectangle(cornerRadius: Radius.xl, style: .continuous))
        .overlay { RoundedRectangle(cornerRadius: Radius.xl, style: .continuous).strokeBorder(Palette.stroke, lineWidth: 1) }
        .elevation(.floating)
        .onAppear {
            query = ""
            highlighted = 0
            isSearchFocused = true
        }
        .onChange(of: query) { highlighted = 0 }
        .onKeyPress(.downArrow) {
            highlighted = min(highlighted + 1, max(results.count - 1, 0))
            return .handled
        }
        .onKeyPress(.upArrow) {
            highlighted = max(highlighted - 1, 0)
            return .handled
        }
        .onKeyPress(.escape) {
            router.isCommandPaletteOpen = false
            return .handled
        }
        .accessibilityElement(children: .contain)
        .accessibilityLabel("Command palette")
    }

    private func row(_ command: Command, isHighlighted: Bool) -> some View {
        HStack(spacing: Spacing.sm) {
            Image(systemName: command.symbol)
                .frame(width: 24, height: 24)
                .foregroundStyle(isHighlighted ? Palette.textPrimary : Palette.textSecondary)
            Text(command.title).font(Typography.body).foregroundStyle(Palette.textPrimary)
            Spacer()
            Text(command.subtitle).font(Typography.caption).foregroundStyle(Palette.textTertiary)
        }
        .padding(.horizontal, Spacing.sm)
        .padding(.vertical, Spacing.xs)
        .background(isHighlighted ? Palette.strokeStrong : .clear, in: RoundedRectangle(cornerRadius: Radius.sm, style: .continuous))
        .contentShape(Rectangle())
        .accessibilityAddTraits(isHighlighted ? [.isButton, .isSelected] : .isButton)
    }

    private func run(_ results: [Command]) {
        guard results.indices.contains(highlighted) else { return }
        router.isCommandPaletteOpen = false
        results[highlighted].perform()
    }
}
