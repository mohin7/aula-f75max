// Renders the AULA Studio app icon into an .icns file.
// Usage: swift Scripts/make-icon.swift Support/AppIcon.icns
import AppKit
import CoreGraphics

let output = CommandLine.arguments.dropFirst().first ?? "Support/AppIcon.icns"
let colorSpace = CGColorSpace(name: CGColorSpace.sRGB)!

func color(_ hex: UInt32, _ alpha: CGFloat = 1) -> CGColor {
    CGColor(
        srgbRed: CGFloat((hex >> 16) & 0xFF) / 255,
        green: CGFloat((hex >> 8) & 0xFF) / 255,
        blue: CGFloat(hex & 0xFF) / 255,
        alpha: alpha
    )
}

func roundedRect(_ rect: CGRect, _ radius: CGFloat) -> CGPath {
    CGPath(roundedRect: rect, cornerWidth: radius, cornerHeight: radius, transform: nil)
}

/// Draws the icon at 1024×1024 design units into a context of any pixel size.
func drawIcon(size: Int) -> CGImage {
    let context = CGContext(
        data: nil, width: size, height: size, bitsPerComponent: 8, bytesPerRow: 0,
        space: colorSpace, bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue
    )!
    let scale = CGFloat(size) / 1024
    context.scaleBy(x: scale, y: scale)

    // macOS icon grid: an 824-point body centered on the 1024 canvas.
    let body = CGRect(x: 100, y: 100, width: 824, height: 824)
    let bodyPath = roundedRect(body, 185)

    // Drop shadow
    context.saveGState()
    context.setShadow(offset: CGSize(width: 0, height: -12), blur: 28, color: color(0x000000, 0.35))
    context.addPath(bodyPath)
    context.setFillColor(color(0x17181C))
    context.fillPath()
    context.restoreGState()

    // Graphite body gradient
    context.saveGState()
    context.addPath(bodyPath)
    context.clip()
    let bodyGradient = CGGradient(colorsSpace: colorSpace, colors: [color(0x2E3036), color(0x121317)] as CFArray, locations: [0, 1])!
    context.drawLinearGradient(bodyGradient, start: CGPoint(x: 512, y: 924), end: CGPoint(x: 512, y: 100), options: [])

    // RGB underglow
    let glow = CGGradient(
        colorsSpace: colorSpace,
        colors: [color(0x3B82F6, 0.95), color(0x8B5CF6, 0.95), color(0xEC4899, 0.95)] as CFArray,
        locations: [0, 0.5, 1]
    )!
    context.saveGState()
    context.setBlendMode(.plusLighter)
    let glowRect = CGRect(x: 180, y: 250, width: 664, height: 90)
    context.addPath(roundedRect(glowRect, 45))
    context.clip()
    context.drawLinearGradient(glow, start: CGPoint(x: 180, y: 0), end: CGPoint(x: 844, y: 0), options: [])
    context.restoreGState()
    context.restoreGState()

    // Soft bloom above the glow strip
    context.saveGState()
    context.addPath(bodyPath)
    context.clip()
    context.setShadow(offset: .zero, blur: 90, color: color(0x8B5CF6, 0.8))
    context.addPath(roundedRect(CGRect(x: 230, y: 270, width: 564, height: 40), 20))
    context.setFillColor(color(0x8B5CF6, 0.5))
    context.fillPath()
    context.restoreGState()

    // Keycap: skirt and face
    let skirt = CGRect(x: 262, y: 300, width: 500, height: 480)
    context.saveGState()
    context.setShadow(offset: CGSize(width: 0, height: -10), blur: 24, color: color(0x000000, 0.55))
    context.addPath(roundedRect(skirt, 90))
    context.setFillColor(color(0x1C1D22))
    context.fillPath()
    context.restoreGState()

    let face = CGRect(x: 312, y: 380, width: 400, height: 370)
    context.saveGState()
    context.addPath(roundedRect(face, 70))
    context.clip()
    let faceGradient = CGGradient(colorsSpace: colorSpace, colors: [color(0x44464E), color(0x2A2B31)] as CFArray, locations: [0, 1])!
    context.drawLinearGradient(faceGradient, start: CGPoint(x: 512, y: 750), end: CGPoint(x: 512, y: 380), options: [])
    context.restoreGState()
    context.addPath(roundedRect(face, 70))
    context.setStrokeColor(color(0xFFFFFF, 0.12))
    context.setLineWidth(4)
    context.strokePath()

    // Legend "A"
    let attributes: [NSAttributedString.Key: Any] = [
        .font: NSFont.systemFont(ofSize: 230, weight: .semibold),
        .foregroundColor: NSColor(white: 0.93, alpha: 1),
    ]
    let legend = NSAttributedString(string: "A", attributes: attributes)
    let line = CTLineCreateWithAttributedString(legend)
    let bounds = CTLineGetBoundsWithOptions(line, .useGlyphPathBounds)
    context.textPosition = CGPoint(x: face.midX - bounds.width / 2 - bounds.minX, y: face.midY - bounds.height / 2 - bounds.minY)
    CTLineDraw(line, context)

    // Knob, top right
    let knobCenter = CGPoint(x: 752, y: 772)
    context.saveGState()
    context.setShadow(offset: CGSize(width: 0, height: -6), blur: 14, color: color(0x000000, 0.5))
    context.addEllipse(in: CGRect(x: knobCenter.x - 78, y: knobCenter.y - 78, width: 156, height: 156))
    context.setFillColor(color(0x8E9098))
    context.fillPath()
    context.restoreGState()
    context.addEllipse(in: CGRect(x: knobCenter.x - 60, y: knobCenter.y - 60, width: 120, height: 120))
    context.setFillColor(color(0x2C2D33))
    context.fillPath()
    context.addPath(roundedRect(CGRect(x: knobCenter.x - 7, y: knobCenter.y + 12, width: 14, height: 40), 7))
    context.setFillColor(color(0xFFFFFF, 0.9))
    context.fillPath()

    return context.makeImage()!
}

// Build an .iconset folder, then convert it with iconutil.
let iconset = URL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent("AppIcon.iconset")
try? FileManager.default.removeItem(at: iconset)
try FileManager.default.createDirectory(at: iconset, withIntermediateDirectories: true)

for base in [16, 32, 128, 256, 512] {
    for multiplier in [1, 2] {
        let pixels = base * multiplier
        let name = multiplier == 1 ? "icon_\(base)x\(base).png" : "icon_\(base)x\(base)@2x.png"
        let rep = NSBitmapImageRep(cgImage: drawIcon(size: pixels))
        try rep.representation(using: .png, properties: [:])!.write(to: iconset.appendingPathComponent(name))
    }
}

let process = Process()
process.executableURL = URL(fileURLWithPath: "/usr/bin/iconutil")
process.arguments = ["-c", "icns", iconset.path, "-o", output]
try process.run()
process.waitUntilExit()
guard process.terminationStatus == 0 else {
    print("iconutil failed")
    exit(1)
}
print("Wrote \(output)")
