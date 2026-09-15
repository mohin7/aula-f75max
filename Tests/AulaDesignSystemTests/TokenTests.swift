import SwiftUI
import Testing
@testable import AulaDesignSystem

@Suite("Design tokens")
struct TokenTests {
    @Test func spacingFollowsFourPointGrid() {
        for value in Spacing.all {
            #expect(value.truncatingRemainder(dividingBy: 4) == 0, "\(value) is off-grid")
        }
    }

    @Test func spacingIsStrictlyIncreasing() {
        #expect(Spacing.all == Spacing.all.sorted())
        #expect(Set(Spacing.all).count == Spacing.all.count)
    }

    @Test func cardRadiiMatchSpec() {
        #expect(Radius.lg == 18)
        #expect(Radius.xl == 24)
        #expect(Radius.xxl == 32)
    }

    @Test @MainActor func toastQueueShowsOneAtATime() {
        let center = ToastCenter()
        center.show(Toast(.info, "First"))
        center.show(Toast(.info, "Second"))
        #expect(center.current?.title == "First")
        center.dismiss()
        #expect(center.current?.title == "Second")
        center.dismiss()
        #expect(center.current == nil)
    }
}
