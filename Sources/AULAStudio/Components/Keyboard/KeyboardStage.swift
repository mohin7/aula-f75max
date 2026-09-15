import AppKit
import AulaDesignSystem
import AulaKit
import SwiftUI

/// Realistic top-down F75 Max: case, keycaps, live RGB, TFT display and knob.
///
/// Rendering has four layers so each one only redraws when it has to:
/// 1. LED light: `LEDLightView`, a Core Animation layer driven by a display link.
///    It's the only per-frame work, and it stops for static effects.
/// 2. Keycap faces: a `Canvas` redrawn on press, hover or selection.
/// 3. Legends as text. They change on key press or legend-mode change.
/// 4. A transparent hit-testing and accessibility layer.
struct KeyboardStage: View {
    @Environment(KeyboardStore.self) private var store
    @Environment(\.studioAccent) private var accent
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    @Binding var selection: Set<String>
    var isInteractive = true

    @State private var hoveredKeyID: String?
    @State private var dragBase: Set<String>?
    @State private var dragPainted: Set<String> = []
    @FocusState private var isFocused: Bool

    /// Case bezel around the plate, in u.
    private let bezel = 0.55

    var body: some View {
        let layout = store.layout
        let totalWidth = layout.width + bezel * 2
        let totalHeight = layout.height + bezel * 2

        GeometryReader { proxy in
            let unit = proxy.size.width / totalWidth
            let origin = CGPoint(x: bezel * unit, y: bezel * unit)

            ZStack(alignment: .topLeading) {
                caseBody(unit: unit)

                lighting(unit: unit)
                    .frame(width: layout.width * unit, height: layout.height * unit)
                    .offset(x: origin.x, y: origin.y)
                    .accessibilityHidden(true)

                ZStack(alignment: .topLeading) {
                    keycaps(unit: unit)
                    legends(unit: unit)
                }
                .frame(width: layout.width * unit, height: layout.height * unit, alignment: .topLeading)
                .offset(x: origin.x, y: origin.y)
                .allowsHitTesting(false)
                .accessibilityHidden(true)

                if let display = layout.display {
                    DisplayScreenPreview()
                        .frame(width: display.rect.width * unit, height: display.rect.height * unit)
                        .offset(x: origin.x + display.rect.x * unit, y: origin.y + display.rect.y * unit)
                }

                if let knob = layout.knob {
                    KnobFace(angle: .degrees(store.knobAngle), isPressed: store.isKnobPressed)
                        .frame(width: knob.rect.width * unit, height: knob.rect.height * unit)
                        .shadow(color: .black.opacity(0.5), radius: unit * 0.08, y: unit * 0.04)
                        .offset(x: origin.x + knob.rect.x * unit, y: origin.y + knob.rect.y * unit)
                        .animation(Motion.animation(Motion.snappy, reduceMotion: reduceMotion), value: store.knobAngle)
                        .animation(Motion.animation(Motion.snappy, reduceMotion: reduceMotion), value: store.isKnobPressed)
                        .accessibilityHidden(true)
                }

                if isInteractive {
                    hitLayer(unit: unit)
                        .frame(width: layout.width * unit, height: layout.height * unit)
                        .offset(x: origin.x, y: origin.y)
                }
            }
        }
        .aspectRatio(totalWidth / totalHeight, contentMode: .fit)
        .accessibilityElement(children: .contain)
        .accessibilityLabel("\(store.layout.name) keyboard")
    }

    // MARK: - Case

    private func caseBody(unit: CGFloat) -> some View {
        let radius = unit * 0.42
        return ZStack {
            RoundedRectangle(cornerRadius: radius, style: .continuous)
                .fill(LinearGradient(colors: [Palette.caseTop, Palette.caseBottom], startPoint: .top, endPoint: .bottom))
            RoundedRectangle(cornerRadius: radius, style: .continuous)
                .strokeBorder(
                    LinearGradient(colors: [.white.opacity(0.22), .white.opacity(0.02)], startPoint: .top, endPoint: .bottom),
                    lineWidth: 1
                )
            // Recessed plate
            RoundedRectangle(cornerRadius: unit * 0.18, style: .continuous)
                .fill(Color(hex: 0x0C0D0F))
                .padding(unit * (bezel - 0.12))
                .shadow(color: .black.opacity(0.6), radius: unit * 0.05, y: unit * 0.02)
        }
        .shadow(color: .black.opacity(0.35), radius: unit * 0.6, y: unit * 0.35)
    }

    // MARK: - LED light

    private func lighting(unit: CGFloat) -> some View {
        LEDLightView(input: .init(
            layout: store.layout,
            settings: store.lighting,
            lastPressTime: store.lastPressTime,
            recentPresses: store.recentPresses
        ))
    }

    // MARK: - Keycap faces (on interaction)

    /// Keycap skirts and tops. Redrawn only when press, hover or selection state changes.
    /// Both are slightly translucent so the LED color tints them.
    private func keycaps(unit: CGFloat) -> some View {
        let layout = store.layout
        let pressed = store.pressedKeyIDs
        let hovered = hoveredKeyID
        let selected = selection
        let accent = accent

        return Canvas { context, _ in
            let faceBase = LEDColor(rgb: 0x2E2F35)
            for key in layout.keys {
                let isPressed = pressed.contains(key.id)
                let isHovered = hovered == key.id
                let skirt = key.rect.cgRect(unit: unit).insetBy(dx: unit * 0.045, dy: unit * 0.045)
                // Skirt: dark but translucent, so it picks up the LED light underneath.
                context.fill(
                    Path(roundedRect: skirt, cornerRadius: unit * 0.12, style: .continuous),
                    with: .color(Color(hex: 0x1B1C20, opacity: 0.72))
                )

                var face = CGRect(
                    x: skirt.minX + unit * 0.085,
                    y: skirt.minY + unit * 0.05,
                    width: skirt.width - unit * 0.17,
                    height: skirt.height - unit * 0.2
                )
                if isPressed { face = face.offsetBy(dx: 0, dy: unit * 0.05) }
                let facePath = Path(roundedRect: face, cornerRadius: unit * 0.09, style: .continuous)
                let top = faceBase.mixed(with: .white, amount: isHovered ? 0.1 : 0.04)
                let bottom = faceBase.scaled(by: isPressed ? 0.75 : 0.9)
                context.fill(
                    facePath,
                    with: .linearGradient(
                        Gradient(colors: [Color(rgb: top).opacity(0.92), Color(rgb: bottom).opacity(0.94)]),
                        startPoint: CGPoint(x: face.midX, y: face.minY),
                        endPoint: CGPoint(x: face.midX, y: face.maxY)
                    )
                )
                context.stroke(facePath, with: .color(.white.opacity(isHovered ? 0.22 : 0.06)), lineWidth: 0.75)

                if selected.contains(key.id) {
                    let ring = Path(roundedRect: skirt.insetBy(dx: -1.5, dy: -1.5), cornerRadius: unit * 0.14, style: .continuous)
                    context.stroke(ring, with: .color(accent), lineWidth: 2)
                }
            }
        }
    }

    // MARK: - Legends

    private func legends(unit: CGFloat) -> some View {
        ZStack(alignment: .topLeading) {
            ForEach(store.layout.keys) { key in
                let text = key.legend.text(for: store.legendMode)
                let isPressed = store.pressedKeyIDs.contains(key.id)
                let rect = key.rect.cgRect(unit: unit)
                let isGlyph = text.count <= 1 || text.unicodeScalars.allSatisfy { $0.value > 0x2000 }
                VStack(spacing: 0) {
                    if let secondary = key.legend.secondary {
                        Text(secondary).font(.system(size: unit * 0.14, weight: .medium)).opacity(0.55)
                    }
                    Text(text).font(.system(size: unit * (isGlyph ? 0.2 : 0.14), weight: .medium))
                }
                .foregroundStyle(Palette.keycapLegend.opacity(0.9))
                .lineLimit(1)
                .minimumScaleFactor(0.5)
                .frame(width: rect.width - unit * 0.3, height: rect.height - unit * 0.35)
                .position(x: rect.midX, y: rect.midY - unit * 0.05 + (isPressed ? unit * 0.05 : 0))
            }
        }
    }

    // MARK: - Interaction

    private func hitLayer(unit: CGFloat) -> some View {
        let layout = store.layout
        func key(at point: CGPoint) -> KeyDefinition? {
            layout.key(at: point.x / unit, point.y / unit)
        }

        return Color.clear
            .contentShape(Rectangle())
            .onContinuousHover { phase in
                switch phase {
                case .active(let point): hoveredKeyID = key(at: point)?.id
                case .ended: hoveredKeyID = nil
                }
            }
            .gesture(
                DragGesture(minimumDistance: 0)
                    .onChanged { gesture in
                        let extending = NSEvent.modifierFlags.contains(.command) || NSEvent.modifierFlags.contains(.shift)
                        if dragBase == nil {
                            dragBase = extending ? selection : []
                            dragPainted = []
                        }
                        if let id = key(at: gesture.location)?.id {
                            dragPainted.insert(id)
                        }
                        // A drag paints keys into the selection. A click is resolved in `onEnded`.
                        if hypot(gesture.translation.width, gesture.translation.height) > 4 {
                            selection = (dragBase ?? []).union(dragPainted)
                        }
                    }
                    .onEnded { gesture in
                        defer { dragBase = nil; dragPainted = [] }
                        guard hypot(gesture.translation.width, gesture.translation.height) <= 4 else { return }
                        let extending = NSEvent.modifierFlags.contains(.command) || NSEvent.modifierFlags.contains(.shift)
                        guard let id = key(at: gesture.location)?.id else {
                            if !extending { selection = [] }
                            return
                        }
                        if extending {
                            if selection.contains(id) { selection.remove(id) } else { selection.insert(id) }
                        } else {
                            selection = selection == [id] ? [] : [id]
                        }
                    }
            )
            .focusable()
            .focused($isFocused)
            .focusEffectDisabled()
            .onKeyPress(.leftArrow) { moveSelection(dx: -1, dy: 0) }
            .onKeyPress(.rightArrow) { moveSelection(dx: 1, dy: 0) }
            .onKeyPress(.upArrow) { moveSelection(dx: 0, dy: -1) }
            .onKeyPress(.downArrow) { moveSelection(dx: 0, dy: 1) }
            .onKeyPress(.escape) {
                guard !selection.isEmpty else { return .ignored }
                selection = []
                return .handled
            }
            .accessibilityChildren {
                ForEach(layout.keys) { key in
                    let rect = key.rect.cgRect(unit: unit)
                    Rectangle()
                        .fill(.clear)
                        .frame(width: rect.width, height: rect.height)
                        .position(x: rect.midX, y: rect.midY)
                        .accessibilityLabel(key.accessibilityName)
                        .accessibilityAddTraits(selection.contains(key.id) ? [.isButton, .isSelected] : .isButton)
                        .accessibilityAction { selection = [key.id] }
                }
            }
    }

    /// Moves the selection to the nearest key in the given direction.
    private func moveSelection(dx: Double, dy: Double) -> KeyPress.Result {
        let keys = store.layout.keys
        guard let current = selection.first.flatMap({ store.keyByID[$0] }) else {
            selection = keys.first.map { [$0.id] } ?? []
            return .handled
        }
        let best = keys
            .filter { $0.id != current.id }
            .compactMap { candidate -> (KeyDefinition, Double)? in
                let offsetX = candidate.rect.midX - current.rect.midX
                let offsetY = candidate.rect.midY - current.rect.midY
                let along = offsetX * dx + offsetY * dy
                guard along > 0.1 else { return nil }
                let across = abs(offsetX * dy) + abs(offsetY * dx)
                return (candidate, along + across * 2)
            }
            .min { $0.1 < $1.1 }
        if let best {
            selection = [best.0.id]
        }
        return .handled
    }
}

extension KeyRect {
    func cgRect(unit: CGFloat) -> CGRect {
        CGRect(x: x * unit, y: y * unit, width: width * unit, height: height * unit)
    }
}

extension Color {
    init(rgb: LEDColor) {
        let c = rgb.components
        self.init(.sRGB, red: c.red, green: c.green, blue: c.blue)
    }
}
