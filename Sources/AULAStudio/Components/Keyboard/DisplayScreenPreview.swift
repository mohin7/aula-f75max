import AulaDesignSystem
import AulaKit
import SwiftUI

/// Mock of the 128×128 TFT home screen: status bar, clock and indicators.
/// Phase 6 swaps in real image and GIF frames from the display engine.
struct DisplayScreenPreview: View {
    @Environment(KeyboardStore.self) private var store
    @AppStorage(PreferenceKey.timeFormat) private var timeFormat = TimeFormatPreference.system.rawValue

    var body: some View {
        GeometryReader { proxy in
            let side = min(proxy.size.width, proxy.size.height)
            let s = side / 128 // one display pixel

            ZStack {
                RoundedRectangle(cornerRadius: s * 10, style: .continuous)
                    .fill(Color.black)
                    .overlay {
                        RoundedRectangle(cornerRadius: s * 10, style: .continuous)
                            .strokeBorder(Color.white.opacity(0.08), lineWidth: max(0.5, s * 2))
                    }

                VStack(spacing: s * 6) {
                    HStack(spacing: s * 4) {
                        Image(systemName: store.primary?.kind.symbolName ?? "wifi.slash")
                            .font(.system(size: s * 13, weight: .bold))
                            .foregroundStyle(store.isConnected ? Color(hex: 0x5AC8FA) : Color(hex: 0xFF6961))
                        Spacer(minLength: 0)
                        if store.capsLockOn {
                            Text("A")
                                .font(.system(size: s * 12, weight: .heavy, design: .rounded))
                                .foregroundStyle(.black)
                                .padding(.horizontal, s * 3)
                                .background(Color(hex: 0x34D399), in: RoundedRectangle(cornerRadius: s * 3))
                        }
                        Text(store.displayedBatteryLevel.map { "\($0)%" } ?? "--")
                            .font(.system(size: s * 12, weight: .bold, design: .rounded).monospacedDigit())
                            .foregroundStyle(.white.opacity(0.85))
                    }

                    TimelineView(.everyMinute) { context in
                        VStack(spacing: 0) {
                            Text(clockText(context.date))
                                .font(.system(size: s * 34, weight: .bold, design: .rounded).monospacedDigit())
                                .foregroundStyle(Color(rgb: accentColor))
                            Text(context.date, format: .dateTime.weekday(.abbreviated).day().month(.abbreviated))
                                .font(.system(size: s * 12, weight: .semibold, design: .rounded))
                                .foregroundStyle(.white.opacity(0.7))
                        }
                    }
                    .frame(maxHeight: .infinity)

                    HStack {
                        Text(store.legendMode == .mac ? "MAC" : "WIN")
                        Spacer(minLength: 0)
                        Text(store.lighting.mode.title.uppercased())
                    }
                    .font(.system(size: s * 10, weight: .bold, design: .rounded))
                    .foregroundStyle(.white.opacity(0.6))
                    .lineLimit(1)
                }
                .padding(s * 10)
            }
            .frame(width: side, height: side)
            .position(x: proxy.size.width / 2, y: proxy.size.height / 2)
        }
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("Keyboard display")
        .accessibilityValue(accessibilitySummary)
    }

    /// Drops the AM/PM marker so the time fits the small screen.
    private func clockText(_ date: Date) -> String {
        let format = TimeFormatPreference(rawValue: timeFormat) ?? .system
        return format.string(from: date)
            .replacingOccurrences(of: " AM", with: "")
            .replacingOccurrences(of: " PM", with: "")
            .replacingOccurrences(of: "\u{202F}AM", with: "")
            .replacingOccurrences(of: "\u{202F}PM", with: "")
    }

    private var accentColor: LEDColor {
        let color = store.lighting.color
        return store.lighting.mode == .off || color.luminance < 0.05 ? .white : color
    }

    private var accessibilitySummary: String {
        [
            store.primary.map { "Connected via \($0.kind.title)" } ?? "Disconnected",
            store.displayedBatteryLevel.map { "Battery \($0) percent" },
            store.capsLockOn ? "Caps Lock on" : nil,
            "\(store.legendMode.title) mode",
        ].compactMap { $0 }.joined(separator: ", ")
    }
}
