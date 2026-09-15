import AulaDesignSystem
import AulaKit
import SwiftUI

/// The dashboard's battery readout: ring, percentage, charging state, estimated time left,
/// and how fresh the reading is.
struct BatteryPanel: View {
    @Environment(KeyboardStore.self) private var store

    /// Manufacturer figures for the 4000 mAh battery: about 30 h with lighting on, 80 h with it off.
    private static let hoursWithLighting = 30.0
    private static let hoursWithoutLighting = 80.0

    var body: some View {
        let level = store.displayedBatteryLevel

        TimelineView(.everyMinute) { _ in
            HStack(spacing: Spacing.md) {
                BatteryRing(
                    level: level,
                    isPluggedIn: store.isPluggedIn,
                    isStale: level != nil && !store.isBatteryLevelLive
                )
                .frame(width: 76, height: 76)

                VStack(alignment: .leading, spacing: Spacing.xxxs) {
                    Text("Battery")
                        .font(Typography.label)
                        .foregroundStyle(Palette.textSecondary)
                    Text(title(level: level))
                        .font(Typography.title)
                        .foregroundStyle(Palette.textPrimary)
                        .contentTransition(.numericText())
                    Text(status(level: level))
                        .font(Typography.caption)
                        .foregroundStyle(statusColor(level: level))
                    if let detail = detail {
                        Text(detail)
                            .font(Typography.caption)
                            .foregroundStyle(Palette.textTertiary)
                    }
                }
                .frame(minWidth: 180, alignment: .leading)
            }
            .padding(.vertical, Spacing.sm)
            .padding(.leading, Spacing.sm)
            .padding(.trailing, Spacing.lg)
            .background(Palette.surface, in: RoundedRectangle(cornerRadius: Radius.xl, style: .continuous))
            .overlay {
                RoundedRectangle(cornerRadius: Radius.xl, style: .continuous).strokeBorder(Palette.stroke, lineWidth: 1)
            }
        }
        .accessibilityElement(children: .combine)
    }

    private func title(level: Int?) -> String {
        if let level { return "\(level)%" }
        switch store.primary?.kind {
        case .bluetooth: return "Reading…"
        case .wired: return "Plugged in"
        default: return "Unknown"
        }
    }

    private func status(level: Int?) -> String {
        switch store.primary?.kind {
        case .wired:
            return "Charging over USB-C"
        case .bluetooth:
            guard let level, store.isBatteryLevelLive else { return "Takes up to 5 seconds" }
            let base = store.lighting.mode == .off ? Self.hoursWithoutLighting : Self.hoursWithLighting
            let hours = Double(level) / 100 * base
            let lightingNote = store.lighting.mode == .off ? "lighting off" : "lighting on"
            return hours >= 1
                ? "About \(Int(hours.rounded())) h left, \(lightingNote)"
                : "Less than an hour left"
        case .dongle:
            return "Not reported over 2.4G yet"
        case nil:
            return level == nil ? "Connect over Bluetooth to read it" : "Keyboard not connected"
        }
    }

    private func statusColor(level: Int?) -> Color {
        if store.isPluggedIn { return Palette.success }
        guard let level, store.isBatteryLevelLive else { return Palette.textSecondary }
        return level <= 20 ? Palette.warning : Palette.textSecondary
    }

    /// Where the number came from, when it isn't live.
    private var detail: String? {
        if store.isBatteryLevelLive { return "Live over Bluetooth" }
        guard let reading = store.lastBatteryReading else {
            return store.isPluggedIn ? "The keyboard reports battery over Bluetooth only" : nil
        }
        let age = reading.date.formatted(.relative(presentation: .named))
        return "Last Bluetooth reading, \(age)"
    }
}
