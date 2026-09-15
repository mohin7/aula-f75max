import AulaDesignSystem
import AulaKit
import SwiftUI

/// Shows whether lighting edits reach the keyboard.
struct LightingSyncBanner: View {
    @Environment(KeyboardStore.self) private var store

    var body: some View {
        let control = store.control
        if let reason = control.unavailableReason {
            Callout(.info, title: "Preview only", message: reason)
        } else if case .failed(let message) = control.lightingStatus {
            Callout(
                .danger,
                title: "Couldn't update the keyboard",
                message: message,
                actionTitle: "Retry",
                action: { control.applyLighting(store.lighting) }
            )
        } else {
            HStack(spacing: Spacing.sm) {
                WriteStatusPill(status: control.lightingStatus, idle: "Connected to keyboard")
                Text("Changes apply to your keyboard over USB-C and stay when you switch to Bluetooth.")
                    .font(Typography.caption)
                    .foregroundStyle(Palette.textTertiary)
                Spacer()
                Button("Send again") { control.applyLighting(store.lighting) }
                    .buttonStyle(.plain)
                    .font(Typography.caption)
                    .foregroundStyle(Palette.textSecondary)
            }
        }
    }
}

/// Status of the most recent write to the keyboard.
struct WriteStatusPill: View {
    let status: KeyboardControl.WriteStatus
    var idle = "Ready"

    var body: some View {
        switch status {
        case .idle: StatusPill(idle, state: .connected)
        case .writing: StatusPill("Applying to keyboard…", state: .warning)
        case .done: StatusPill("Keyboard confirmed", state: .connected)
        case .failed: StatusPill("Not applied", state: .disconnected)
        }
    }
}
