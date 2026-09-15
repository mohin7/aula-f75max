import SwiftUI

/// Round color swatch with a selection ring.
public struct ColorSwatch: View {
    private let color: Color
    private let isSelected: Bool
    private let action: () -> Void

    public init(_ color: Color, isSelected: Bool, action: @escaping () -> Void) {
        self.color = color
        self.isSelected = isSelected
        self.action = action
    }

    public var body: some View {
        Button(action: action) {
            Circle()
                .fill(color)
                .overlay { Circle().strokeBorder(.white.opacity(0.25), lineWidth: 1) }
                .padding(3)
                .overlay {
                    Circle().strokeBorder(isSelected ? Palette.textPrimary : .clear, lineWidth: 2)
                }
                .frame(width: 26, height: 26)
                .contentShape(Circle())
        }
        .buttonStyle(.plain)
        .accessibilityAddTraits(isSelected ? .isSelected : [])
    }
}

/// Hex input that only commits valid `#RRGGBB` values.
public struct HexColorField: View {
    @Binding private var hex: String
    @State private var draft: String = ""
    @FocusState private var isFocused: Bool

    public init(hex: Binding<String>) {
        self._hex = hex
    }

    private var isValid: Bool {
        let text = draft.hasPrefix("#") ? String(draft.dropFirst()) : draft
        return (text.count == 6 || text.count == 3) && UInt32(text, radix: 16) != nil
    }

    public var body: some View {
        TextField("Hex", text: $draft)
            .textFieldStyle(.plain)
            .font(Typography.mono)
            .focused($isFocused)
            .padding(.horizontal, Spacing.sm)
            .padding(.vertical, Spacing.xs - 2)
            .background(Palette.surfaceSunken, in: RoundedRectangle(cornerRadius: Radius.sm, style: .continuous))
            .overlay {
                RoundedRectangle(cornerRadius: Radius.sm, style: .continuous)
                    .strokeBorder(isValid || draft.isEmpty ? Palette.stroke : Palette.danger, lineWidth: 1)
            }
            .onAppear { draft = hex }
            .onChange(of: hex) { _, newValue in
                if !isFocused { draft = newValue }
            }
            .onSubmit(commit)
            .onChange(of: isFocused) { _, focused in
                if !focused { commit() }
            }
            .accessibilityLabel("Hex color")
    }

    private func commit() {
        if isValid {
            let text = draft.hasPrefix("#") ? String(draft.dropFirst()) : draft
            let expanded = text.count == 3 ? text.map { "\($0)\($0)" }.joined() : text
            hex = "#" + expanded.uppercased()
        }
        draft = hex
    }
}

/// Hue strip: drag to pick a fully saturated hue.
public struct HueStrip: View {
    @Binding private var hue: Double

    public init(hue: Binding<Double>) {
        self._hue = hue
    }

    public var body: some View {
        GeometryReader { proxy in
            ZStack(alignment: .leading) {
                LinearGradient(
                    colors: stride(from: 0.0, through: 1.0, by: 1.0 / 6).map { Color(hue: $0, saturation: 1, brightness: 1) },
                    startPoint: .leading,
                    endPoint: .trailing
                )
                .clipShape(Capsule())
                .overlay { Capsule().strokeBorder(Palette.stroke, lineWidth: 1) }
                Circle()
                    .fill(Color(hue: hue / 360, saturation: 1, brightness: 1))
                    .overlay { Circle().strokeBorder(.white, lineWidth: 2.5) }
                    .shadow(color: .black.opacity(0.3), radius: 2, y: 1)
                    .frame(width: 18, height: 18)
                    .offset(x: proxy.size.width * hue / 360 - 9)
            }
            .contentShape(Rectangle())
            .gesture(DragGesture(minimumDistance: 0).onChanged { gesture in
                hue = min(max(gesture.location.x / proxy.size.width, 0), 0.9999) * 360
            })
        }
        .frame(height: 18)
        .accessibilityElement()
        .accessibilityLabel("Hue")
        .accessibilityValue("\(Int(hue)) degrees")
        .accessibilityAdjustableAction { direction in
            hue = (hue + (direction == .increment ? 10 : -10) + 360).truncatingRemainder(dividingBy: 360)
        }
    }
}
