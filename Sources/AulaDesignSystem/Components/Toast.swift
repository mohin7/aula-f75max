import Observation
import SwiftUI

public struct Toast: Identifiable, Equatable, Sendable {
    public enum Style: Sendable { case info, success, warning, error }

    public let id = UUID()
    public let style: Style
    public let title: String
    public let message: String?

    public init(_ style: Style, _ title: String, message: String? = nil) {
        self.style = style
        self.title = title
        self.message = message
    }
}

/// Queue of transient notifications. Inject once at the root and call `show` from anywhere.
@MainActor
@Observable
public final class ToastCenter {
    public private(set) var current: Toast?
    private var queue: [Toast] = []
    private var dismissTask: Task<Void, Never>?

    public init() {}

    public func show(_ toast: Toast, duration: Duration = .seconds(2.5)) {
        if current == nil {
            present(toast, duration: duration)
        } else {
            queue.append(toast)
        }
    }

    public func dismiss() {
        dismissTask?.cancel()
        current = nil
        if !queue.isEmpty {
            present(queue.removeFirst(), duration: .seconds(2.5))
        }
    }

    private func present(_ toast: Toast, duration: Duration) {
        current = toast
        dismissTask?.cancel()
        dismissTask = Task { [weak self] in
            try? await Task.sleep(for: duration)
            guard !Task.isCancelled else { return }
            self?.dismiss()
        }
    }
}

private struct ToastView: View {
    let toast: Toast

    private var symbol: (String, Color) {
        switch toast.style {
        case .info: ("info.circle.fill", Palette.info)
        case .success: ("checkmark.circle.fill", Palette.success)
        case .warning: ("exclamationmark.triangle.fill", Palette.warning)
        case .error: ("xmark.octagon.fill", Palette.danger)
        }
    }

    var body: some View {
        HStack(spacing: Spacing.sm) {
            Image(systemName: symbol.0).foregroundStyle(symbol.1)
            VStack(alignment: .leading, spacing: 0) {
                Text(toast.title).font(Typography.label).foregroundStyle(Palette.textPrimary)
                if let message = toast.message {
                    Text(message).font(Typography.caption).foregroundStyle(Palette.textSecondary)
                }
            }
        }
        .padding(.horizontal, Spacing.md)
        .padding(.vertical, Spacing.sm)
        .background(.regularMaterial, in: Capsule())
        .overlay { Capsule().strokeBorder(Palette.stroke, lineWidth: 1) }
        .elevation(.floating)
        .accessibilityElement(children: .combine)
        .accessibilityAddTraits(.updatesFrequently)
    }
}

extension View {
    /// Shows toasts from `center` at the bottom of this view.
    public func toastOverlay(_ center: ToastCenter) -> some View {
        modifier(ToastOverlay(center: center))
    }
}

private struct ToastOverlay: ViewModifier {
    let center: ToastCenter
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    func body(content: Content) -> some View {
        content.overlay(alignment: .bottom) {
            ZStack {
                if let toast = center.current {
                    ToastView(toast: toast)
                        .id(toast.id)
                        .transition(reduceMotion ? .opacity : .move(edge: .bottom).combined(with: .opacity))
                        .onTapGesture { center.dismiss() }
                }
            }
            .padding(.bottom, Spacing.xl)
            .animation(Motion.animation(Motion.smooth, reduceMotion: reduceMotion), value: center.current)
        }
    }
}
