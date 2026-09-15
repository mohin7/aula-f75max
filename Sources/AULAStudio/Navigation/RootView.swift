import AulaDesignSystem
import AulaKit
import SwiftUI

struct RootView: View {
    @Environment(KeyboardStore.self) private var store
    @Environment(AppRouter.self) private var router
    @Environment(ToastCenter.self) private var toasts
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    @AppStorage(PreferenceKey.accentFollowsLighting) private var accentFollowsLighting = true

    var body: some View {
        @Bindable var router = router

        NavigationSplitView {
            List(selection: $router.section) {
                Section {
                    ForEach(AppSection.allCases) { section in
                        Label(section.title, systemImage: section.symbol)
                            .tag(section)
                    }
                }
            }
            .navigationSplitViewColumnWidth(min: 190, ideal: 210, max: 260)
            .safeAreaInset(edge: .bottom) {
                SidebarDeviceFooter()
                    .padding(Spacing.sm)
            }
        } detail: {
            detail(for: router.section)
                .toolbar {
                    ToolbarItem(placement: .primaryAction) {
                        Button {
                            router.isCommandPaletteOpen = true
                        } label: {
                            Label("Command Palette", systemImage: "command")
                        }
                        .help("Command Palette (⌘K)")
                    }
                }
        }
        .overlay {
            if router.isCommandPaletteOpen {
                ZStack(alignment: .top) {
                    Color.black.opacity(0.18)
                        .ignoresSafeArea()
                        .onTapGesture { router.isCommandPaletteOpen = false }
                    CommandPalette()
                        .padding(.top, 96)
                }
                .transition(.opacity)
            }
        }
        .animation(Motion.animation(Motion.snappy, reduceMotion: reduceMotion), value: router.isCommandPaletteOpen)
        .toastOverlay(toasts)
        .environment(\.studioAccent, accent)
        .tint(accent)
        .onChange(of: store.primary?.id) { old, new in
            guard old != new else { return }
            if let primary = store.primary {
                toasts.show(Toast(.success, "\(primary.productName) connected", message: primary.kind.title))
            } else if old != nil {
                toasts.show(Toast(.warning, "Keyboard disconnected"))
            }
        }
    }

    @ViewBuilder
    private func detail(for section: AppSection) -> some View {
        switch section {
        case .dashboard: DashboardView()
        case .lighting: LightingView()
        case .display: DisplayView()
        case .settings: SettingsView()
        case .keymap, .macros, .profiles, .firmware: UpcomingFeatureView(section: section)
        }
    }

    private var accent: Color {
        accentFollowsLighting ? store.studioAccent : Color(hex: 0x6E7BFF)
    }
}

private struct SidebarDeviceFooter: View {
    @Environment(KeyboardStore.self) private var store

    var body: some View {
        HStack(spacing: Spacing.xs) {
            Image(systemName: store.primary?.kind.symbolName ?? "cable.connector.slash")
                .foregroundStyle(store.isConnected ? Palette.success : Palette.textTertiary)
                .frame(width: 20)
            VStack(alignment: .leading, spacing: 0) {
                Text(store.primary?.productName ?? "No keyboard")
                    .font(Typography.label)
                    .lineLimit(1)
                Text(store.primary?.kind.title ?? "Waiting for connection")
                    .font(Typography.caption)
                    .foregroundStyle(Palette.textSecondary)
            }
            Spacer(minLength: 0)
            if store.isConnected {
                HStack(spacing: Spacing.xxs) {
                    if let level = store.displayedBatteryLevel {
                        Text("\(level)%")
                            .font(Typography.caption.monospacedDigit())
                            .foregroundStyle(store.isBatteryLevelLive ? Palette.textSecondary : Palette.textTertiary)
                    }
                    BatteryGauge(level: store.displayedBatteryLevel, isCharging: store.isCharging)
                        .opacity(store.isBatteryLevelLive || store.isPluggedIn ? 1 : 0.6)
                }
            }
        }
        .padding(Spacing.sm)
        .background(Palette.surfaceSunken.opacity(0.6), in: RoundedRectangle(cornerRadius: Radius.md, style: .continuous))
        .accessibilityElement(children: .combine)
    }
}
