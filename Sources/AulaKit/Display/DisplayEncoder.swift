import CoreGraphics
import Foundation
import ImageIO

/// Converts images and animated GIFs into the F75 Max screen format.
///
/// Stream layout (verified on hardware, 128×128, up to 255 frames):
/// - 256-byte header: `[0]` frame count, `[1 + i]` delay of frame `i` in 2 ms units (30–500 ms).
/// - Each frame: 128×128 RGB565, little-endian.
/// - Zero-padded to a whole number of 4096-byte chunks.
public enum DisplayEncoder {
    public static let width = 128
    public static let height = 128
    public static let headerLength = 256
    public static let maxFrames = 255
    public static let chunkLength = 4096
    public static let bytesPerFrame = width * height * 2
    public static let delayRange = 30...500

    public enum FitMode: String, CaseIterable, Codable, Sendable, Identifiable {
        /// Whole image visible, letterboxed on black.
        case fit
        /// Fills the screen, cropping the edges.
        case fill
        case stretch

        public var id: String { rawValue }
        public var title: String {
            switch self {
            case .fit: "Fit"
            case .fill: "Fill"
            case .stretch: "Stretch"
            }
        }
    }

    public struct Frame: Sendable {
        /// 128×128 sRGB, already fitted.
        public let image: CGImage
        public let delayMilliseconds: Int
    }

    public enum EncoderError: LocalizedError {
        case unreadable
        case noFrames

        public var errorDescription: String? {
            switch self {
            case .unreadable: "The file isn't an image AULA Studio can read."
            case .noFrames: "The image has no frames."
            }
        }
    }

    /// Decodes up to 255 frames and fits them to the screen.
    public static func frames(from data: Data, fit: FitMode) throws -> [Frame] {
        guard let source = CGImageSourceCreateWithData(data as CFData, nil) else { throw EncoderError.unreadable }
        let count = min(CGImageSourceGetCount(source), maxFrames)
        guard count > 0 else { throw EncoderError.noFrames }

        var frames: [Frame] = []
        frames.reserveCapacity(count)
        // Animated images draw each frame over the previous one.
        let canvas = makeContext()
        for index in 0..<count {
            guard let image = CGImageSourceCreateImageAtIndex(source, index, nil), let canvas else { continue }
            if index == 0 {
                canvas.setFillColor(CGColor(srgbRed: 0, green: 0, blue: 0, alpha: 1))
                canvas.fill(CGRect(x: 0, y: 0, width: width, height: height))
            }
            canvas.interpolationQuality = .high
            canvas.draw(image, in: drawRect(imageWidth: image.width, imageHeight: image.height, fit: fit))
            guard let rendered = canvas.makeImage() else { continue }
            frames.append(Frame(image: rendered, delayMilliseconds: delay(source: source, index: index)))
        }
        guard !frames.isEmpty else { throw EncoderError.unreadable }
        return frames
    }

    /// Builds the upload stream from fitted frames.
    public static func stream(for frames: [Frame]) -> Data {
        let frames = Array(frames.prefix(maxFrames))
        let payloadLength = headerLength + frames.count * bytesPerFrame
        let chunkCount = (payloadLength + chunkLength - 1) / chunkLength
        var stream = [UInt8](repeating: 0, count: chunkCount * chunkLength)

        stream[0] = UInt8(frames.count)
        for (index, frame) in frames.enumerated() {
            stream[1 + index] = delayByte(milliseconds: frame.delayMilliseconds)
        }

        var pixels = [UInt8](repeating: 0, count: width * height * 4)
        for (index, frame) in frames.enumerated() {
            render(frame.image, into: &pixels)
            let offset = headerLength + index * bytesPerFrame
            for pixel in 0..<(width * height) {
                let red = UInt16(pixels[pixel * 4]) >> 3
                let green = UInt16(pixels[pixel * 4 + 1]) >> 2
                let blue = UInt16(pixels[pixel * 4 + 2]) >> 3
                let value = red << 11 | green << 5 | blue
                stream[offset + pixel * 2] = UInt8(value & 0xFF)
                stream[offset + pixel * 2 + 1] = UInt8(value >> 8)
            }
        }
        return Data(stream)
    }

    /// Delay in 2 ms units, clamped to 30–500 ms.
    public static func delayByte(milliseconds: Int) -> UInt8 {
        let clamped = min(max(milliseconds, delayRange.lowerBound), delayRange.upperBound)
        return UInt8(clamping: Int((Double(clamped) / 2).rounded()))
    }

    static func drawRect(imageWidth: Int, imageHeight: Int, fit: FitMode) -> CGRect {
        let target = CGSize(width: width, height: height)
        guard fit != .stretch, imageWidth > 0, imageHeight > 0 else { return CGRect(origin: .zero, size: target) }
        let scaleX = target.width / CGFloat(imageWidth)
        let scaleY = target.height / CGFloat(imageHeight)
        let scale = fit == .fit ? min(scaleX, scaleY) : max(scaleX, scaleY)
        let size = CGSize(width: CGFloat(imageWidth) * scale, height: CGFloat(imageHeight) * scale)
        return CGRect(x: (target.width - size.width) / 2, y: (target.height - size.height) / 2, width: size.width, height: size.height)
    }

    private static func delay(source: CGImageSource, index: Int) -> Int {
        guard let properties = CGImageSourceCopyPropertiesAtIndex(source, index, nil) as? [CFString: Any] else { return 100 }
        let dictionaries = [kCGImagePropertyGIFDictionary, kCGImagePropertyPNGDictionary, kCGImagePropertyWebPDictionary]
        for key in dictionaries {
            guard let dictionary = properties[key] as? [CFString: Any] else { continue }
            let unclamped = (dictionary[kCGImagePropertyGIFUnclampedDelayTime] ?? dictionary[kCGImagePropertyAPNGUnclampedDelayTime] ?? dictionary[kCGImagePropertyWebPUnclampedDelayTime]) as? Double
            let clamped = (dictionary[kCGImagePropertyGIFDelayTime] ?? dictionary[kCGImagePropertyAPNGDelayTime] ?? dictionary[kCGImagePropertyWebPDelayTime]) as? Double
            if let seconds = unclamped ?? clamped, seconds > 0 {
                return Int((seconds * 1000).rounded())
            }
        }
        return 100
    }

    private static func makeContext() -> CGContext? {
        CGContext(
            data: nil, width: width, height: height, bitsPerComponent: 8, bytesPerRow: width * 4,
            space: CGColorSpace(name: CGColorSpace.sRGB)!,
            bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue
        )
    }

    private static func render(_ image: CGImage, into pixels: inout [UInt8]) {
        pixels.withUnsafeMutableBytes { buffer in
            guard let context = CGContext(
                data: buffer.baseAddress, width: width, height: height, bitsPerComponent: 8, bytesPerRow: width * 4,
                space: CGColorSpace(name: CGColorSpace.sRGB)!,
                bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue
            ) else { return }
            context.setFillColor(CGColor(srgbRed: 0, green: 0, blue: 0, alpha: 1))
            context.fill(CGRect(x: 0, y: 0, width: width, height: height))
            context.draw(image, in: CGRect(x: 0, y: 0, width: width, height: height))
        }
    }
}
