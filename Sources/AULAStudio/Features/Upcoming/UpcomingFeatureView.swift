import AulaDesignSystem
import AulaKit
import SwiftUI

/// Roadmap screen for sections whose engines land in later phases. It's honest
/// about what's planned, which link each feature needs, and how much of the
/// protocol is known today.
struct UpcomingFeatureView: View {
    @Environment(KeyboardStore.self) private var store
    let section: AppSection

    private struct Plan {
        let phase: Int
        let summary: String
        let features: [String]
        let requires: String
        let protocolStatus: String
    }

    private var plan: Plan {
        switch section {
        case .keymap:
            Plan(
                phase: 7,
                summary: "Remap any key, layer and knob action, with conflict detection.",
                features: ["Drag-and-drop remapping", "Media keys, app launch, Shortcuts, shell commands", "Knob rotate, press and long-press actions", "Hyper key"],
                requires: "USB-C (on-board), or any link for Mac-side remaps",
                protocolStatus: "The on-board keymap write format isn't documented yet, so it needs capture work. Mac-side remapping works without it."
            )
        case .macros:
            Plan(
                phase: 7,
                summary: "Record, edit and loop macros on a visual timeline.",
                features: ["Live recording", "Keyboard, mouse and delay steps", "Loops, repeats, hold and release", "Per-app macros"],
                requires: "Any link (macros run on the Mac)",
                protocolStatus: "No firmware protocol needed. Runs in a Mac background agent."
            )
        case .profiles:
            Plan(
                phase: 9,
                summary: "Unlimited profiles that switch automatically based on the frontmost app.",
                features: ["Work, Gaming, Coding, Figma presets", "Auto-switch by app", "JSON import and export with versioned migrations", "Smart automations (battery, charger, sunset)"],
                requires: "USB-C or 2.4G to apply lighting and settings",
                protocolStatus: "Built on the Phase 5 and Phase 7 engines."
            )
        case .firmware:
            Plan(
                phase: 8,
                summary: "Check the firmware version and install updates safely.",
                features: ["Version detection", "Download and verify", "Progress and recovery mode", "Rollback"],
                requires: "USB-C",
                protocolStatus: "Blocked: AULA doesn't publish firmware images or an update protocol. A bad flash can brick the keyboard, so this ships only with vendor images and a documented bootloader."
            )
        default:
            Plan(phase: 0, summary: "", features: [], requires: "", protocolStatus: "")
        }
    }

    var body: some View {
        let plan = plan
        ScrollView {
            VStack(alignment: .leading, spacing: Spacing.xl) {
                VStack(alignment: .leading, spacing: Spacing.xs) {
                    Text("Phase \(plan.phase)")
                        .font(Typography.eyebrow)
                        .textCase(.uppercase)
                        .foregroundStyle(Palette.textTertiary)
                    Text(section.title).font(Typography.largeTitle).foregroundStyle(Palette.textPrimary)
                    Text(plan.summary).font(Typography.body).foregroundStyle(Palette.textSecondary)
                }

                StudioCard(radius: Radius.xl, padding: Spacing.lg) {
                    VStack(alignment: .leading, spacing: Spacing.md) {
                        SectionHeader("Planned")
                        ForEach(plan.features, id: \.self) { feature in
                            Label(feature, systemImage: "circle.dashed")
                                .font(Typography.body)
                                .foregroundStyle(Palette.textPrimary)
                        }
                    }
                }

                HStack(alignment: .top, spacing: Spacing.md) {
                    StatCard("Requires", value: plan.requires.components(separatedBy: " (").first ?? plan.requires, detail: plan.requires.contains("(") ? plan.requires : nil, symbol: "cable.connector")
                    StudioCard {
                        VStack(alignment: .leading, spacing: Spacing.xs) {
                            Text("Protocol status").font(Typography.label).foregroundStyle(Palette.textSecondary)
                            Text(plan.protocolStatus).font(Typography.body).foregroundStyle(Palette.textPrimary)
                        }
                    }
                }
            }
            .padding(Spacing.xl)
            .pageContainer(.readable)
        }
        .background(Palette.canvas)
    }
}
