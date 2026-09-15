import AppKit
import AulaKit
import QuartzCore
import SwiftUI

/// Renders the animated LED light for the keyboard stage.
///
/// SwiftUI's `TimelineView` re-runs the whole window's layout pass every tick,
/// which cost ~25% CPU at 60 fps. This view steps outside the SwiftUI graph:
/// a display link paints a tiny bitmap (a few px per key) straight into a
/// `CALayer`, and Core Animation upscales it with linear filtering, which also
/// gives the soft LED bloom. SwiftUI only pushes new inputs when settings or
/// key presses change.
struct LEDLightView: NSViewRepresentable {
    struct Input: Equatable {
        var layout: KeyboardLayout
        var settings: LightingSettings
        /// Reference-date seconds of each key's last press.
        var lastPressTime: [String: TimeInterval]
        var recentPresses: [KeyboardStore.PressRecord]
    }

    let input: Input

    func makeNSView(context: Context) -> LEDLightNSView {
        LEDLightNSView()
    }

    func updateNSView(_ view: LEDLightNSView, context: Context) {
        view.input = input
    }
}

final class LEDLightNSView: NSView {
    var input: LEDLightView.Input? {
        didSet {
            guard input != oldValue else { return }
            keyIndex = input.map { Dictionary(uniqueKeysWithValues: $0.layout.keys.map { ($0.id, $0) }) } ?? [:]
            renderFrame()
            updateDisplayLink()
        }
    }

    private static let pixelsPerUnit = 6.0
    private var keyIndex: [String: KeyDefinition] = [:]
    private var displayLink: CADisplayLink?
    private var context: CGContext?

    override init(frame: NSRect) {
        super.init(frame: frame)
        wantsLayer = true
        layer?.magnificationFilter = .linear
        layer?.contentsGravity = .resize
        layer?.actions = ["contents": NSNull()]
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    override func viewDidMoveToWindow() {
        super.viewDidMoveToWindow()
        updateDisplayLink()
    }

    /// Runs the display link only while something is moving and the view is on screen.
    private func updateDisplayLink() {
        let needsAnimation = window != nil && (input.map { settings in
            settings.settings.mode.isAnimated || !settings.recentPresses.isEmpty
        } ?? false)

        if needsAnimation, displayLink == nil {
            let link = displayLink(target: self, selector: #selector(step))
            link.add(to: .main, forMode: .common)
            displayLink = link
        } else if !needsAnimation, let link = displayLink {
            link.invalidate()
            displayLink = nil
        }
    }

    @objc private func step(_ link: CADisplayLink) {
        // Skip work while the window is hidden, minimized or fully covered.
        guard window?.occlusionState.contains(.visible) == true else { return }
        renderFrame()
    }

    private func renderFrame() {
        guard let input else { return }
        let layout = input.layout
        let ppu = Self.pixelsPerUnit
        let width = Int((layout.width * ppu).rounded(.up))
        let height = Int((layout.height * ppu).rounded(.up))

        if context?.width != width || context?.height != height {
            context = CGContext(
                data: nil, width: width, height: height, bitsPerComponent: 8, bytesPerRow: width * 4,
                space: CGColorSpace(name: CGColorSpace.sRGB)!,
                bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue
            )
        }
        guard let context else { return }
        context.clear(CGRect(x: 0, y: 0, width: width, height: height))

        let time = Date.timeIntervalSinceReferenceDate
        let engine = LightingPreviewEngine(settings: input.settings, boardWidth: layout.width, boardHeight: layout.height)
        let presses: [LightingPreviewEngine.Press] = input.recentPresses.compactMap { press in
            guard let key = keyIndex[press.keyID] else { return nil }
            return .init(x: key.rect.midX, y: key.rect.midY, age: time - press.time)
        }

        for (index, key) in layout.keys.enumerated() {
            let led = engine.color(
                x: key.rect.midX, y: key.rect.midY, time: time,
                pressAge: input.lastPressTime[key.id].map { time - $0 },
                seed: Double((index &* 7919) % 101) / 101,
                presses: presses
            )
            guard led != .black else { continue }
            let c = led.components
            context.setFillColor(red: c.red, green: c.green, blue: c.blue, alpha: 1)
            // CoreGraphics has its origin at the bottom left. The half-pixel inset leaves a dark seam between keys.
            context.fill(CGRect(
                x: key.rect.x * ppu + 0.5,
                y: Double(height) - key.rect.maxY * ppu + 0.5,
                width: key.rect.width * ppu - 1,
                height: key.rect.height * ppu - 1
            ))
        }

        CATransaction.begin()
        CATransaction.setDisableActions(true)
        layer?.contents = context.makeImage()
        CATransaction.commit()
    }
}
