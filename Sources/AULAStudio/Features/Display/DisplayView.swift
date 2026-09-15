import AulaDesignSystem
import AulaKit
import SwiftUI
import UniformTypeIdentifiers

/// Upload pictures and animated GIFs to the keyboard's 128×128 screen.
struct DisplayView: View {
    @Environment(KeyboardStore.self) private var store
    @Environment(ToastCenter.self) private var toasts

    @State private var fileName: String?
    @State private var sourceData: Data?
    @State private var frames: [DisplayEncoder.Frame] = []
    @State private var sourceFrameCount = 0
    @State private var fit: DisplayEncoder.FitMode = .fill
    @State private var isImporting = false
    @State private var isDecoding = false
    @State private var decodeError: String?
    @State private var isDropTargeted = false

    /// Measured on the F75 Max: about 145 ms per 4096-byte chunk over USB-C.
    private static let secondsPerChunk = 0.145

    var body: some View {
        let control = store.control

        ScrollView {
            VStack(alignment: .leading, spacing: Spacing.xl) {
                VStack(alignment: .leading, spacing: Spacing.xxs) {
                    Text("Display").font(Typography.largeTitle).foregroundStyle(Palette.textPrimary)
                    Text("Put a picture or animated GIF on your keyboard's screen.")
                        .font(Typography.body)
                        .foregroundStyle(Palette.textSecondary)
                }

                if let reason = control.unavailableReason {
                    Callout(.info, title: "Connect USB-C to upload", message: reason)
                }

                HStack(alignment: .top, spacing: Spacing.xl) {
                    preview
                    details(control: control)
                }
            }
            .padding(Spacing.xl)
            .pageContainer(.regular)
        }
        .background(Palette.canvas)
        .fileImporter(isPresented: $isImporting, allowedContentTypes: [.gif, .png, .jpeg, .heic, .webP, .bmp, .tiff, .image]) { result in
            if case .success(let url) = result { load(url) }
        }
        .onChange(of: fit) { reencode() }
    }

    // MARK: Preview

    private var preview: some View {
        VStack(spacing: Spacing.sm) {
            ZStack {
                RoundedRectangle(cornerRadius: Radius.xl, style: .continuous)
                    .fill(Color.black)
                if frames.isEmpty {
                    VStack(spacing: Spacing.sm) {
                        Image(systemName: isDecoding ? "hourglass" : "photo.badge.plus")
                            .font(.system(size: 36, weight: .light))
                        Text(isDecoding ? "Preparing…" : "Drop an image or GIF here")
                            .font(Typography.label)
                    }
                    .foregroundStyle(.white.opacity(0.6))
                } else {
                    AnimatedFramesView(frames: frames)
                        .frame(width: 384, height: 384)
                        .clipShape(RoundedRectangle(cornerRadius: Radius.sm, style: .continuous))
                }
            }
            .frame(width: 416, height: 416)
            .overlay {
                RoundedRectangle(cornerRadius: Radius.xl, style: .continuous)
                    .strokeBorder(isDropTargeted ? store.studioAccent : Palette.strokeStrong, lineWidth: isDropTargeted ? 3 : 1)
            }
            .dropDestination(for: URL.self) { urls, _ in
                guard let url = urls.first else { return false }
                load(url)
                return true
            } isTargeted: { isDropTargeted = $0 }
            .accessibilityLabel(frames.isEmpty ? "Screen preview, empty" : "Screen preview, \(frames.count) frames")

            Text("Actual size on the keyboard: 128 × 128 pixels")
                .font(Typography.caption)
                .foregroundStyle(Palette.textTertiary)
        }
    }

    // MARK: Details

    private func details(control: KeyboardControl) -> some View {
        VStack(alignment: .leading, spacing: Spacing.lg) {
            StudioCard(padding: Spacing.lg) {
                VStack(alignment: .leading, spacing: Spacing.md) {
                    SectionHeader("Image", subtitle: fileName ?? "PNG, JPEG, GIF, HEIC, WebP, BMP or TIFF")
                    HStack(spacing: Spacing.xs) {
                        Button(frames.isEmpty ? "Choose File…" : "Choose Another…") { isImporting = true }
                            .buttonStyle(.studioSecondary)
                            .disabled(control.isUploading)
                        if !frames.isEmpty {
                            Button("Clear") { clear() }
                                .buttonStyle(.studioSecondary)
                                .disabled(control.isUploading)
                        }
                    }
                    VStack(alignment: .leading, spacing: Spacing.xs) {
                        Text("Sizing").font(Typography.label).foregroundStyle(Palette.textSecondary)
                        StudioSegmentedControl(DisplayEncoder.FitMode.allCases, selection: $fit) { Text($0.title) }
                            .disabled(control.isUploading)
                    }
                    if let decodeError {
                        Callout(.danger, title: "Couldn't open this file", message: decodeError)
                    }
                    if !frames.isEmpty {
                        VStack(spacing: Spacing.xs) {
                            PropertyRow("Frames", value: frameSummary)
                            PropertyRow("Length", value: String(format: "%.1f s", Double(frames.map(\.delayMilliseconds).reduce(0, +)) / 1000))
                            PropertyRow("Upload time", value: uploadEstimate)
                        }
                    }
                }
            }

            StudioCard(padding: Spacing.lg) {
                VStack(alignment: .leading, spacing: Spacing.md) {
                    SectionHeader("Upload")
                    if let upload = control.upload {
                        ProgressView(value: upload.fraction)
                        HStack {
                            Text("\(Int(upload.fraction * 100))% · \(upload.sent) of \(upload.total) parts")
                            Spacer()
                            if let remaining = upload.remaining {
                                Text("About \(Self.format(seconds: remaining)) left")
                            }
                        }
                        .font(Typography.caption)
                        .foregroundStyle(Palette.textSecondary)
                        Text("Keep the cable connected until the upload finishes.")
                            .font(Typography.caption)
                            .foregroundStyle(Palette.textTertiary)
                    } else {
                        Button {
                            Task { await upload() }
                        } label: {
                            Label("Upload to Keyboard", systemImage: "square.and.arrow.up").frame(maxWidth: .infinity)
                        }
                        .buttonStyle(.studioPrimary)
                        .disabled(frames.isEmpty || !control.isAvailable || isDecoding)

                        switch control.uploadStatus {
                        case .done:
                            Callout(.success, title: "On your keyboard", message: "The keyboard confirmed every part of the upload.")
                        case .failed(let message):
                            Callout(.danger, title: "Upload didn't finish", message: message)
                        default:
                            EmptyView()
                        }
                    }
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private var frameSummary: String {
        if sourceFrameCount > DisplayEncoder.maxFrames {
            return "\(frames.count) (first \(DisplayEncoder.maxFrames) of \(sourceFrameCount))"
        }
        return "\(frames.count)"
    }

    private var uploadEstimate: String {
        let bytes = DisplayEncoder.headerLength + frames.count * DisplayEncoder.bytesPerFrame
        let chunks = (bytes + DisplayEncoder.chunkLength - 1) / DisplayEncoder.chunkLength
        return "About " + Self.format(seconds: Double(chunks) * Self.secondsPerChunk)
    }

    private static func format(seconds: Double) -> String {
        seconds < 60 ? "\(max(1, Int(seconds.rounded()))) s" : "\(Int(seconds) / 60) min \(Int(seconds) % 60) s"
    }

    // MARK: Actions

    private func load(_ url: URL) {
        let accessing = url.startAccessingSecurityScopedResource()
        defer { if accessing { url.stopAccessingSecurityScopedResource() } }
        do {
            sourceData = try Data(contentsOf: url)
            fileName = url.lastPathComponent
            store.control.clearUploadStatus()
            reencode()
        } catch {
            decodeError = error.localizedDescription
        }
    }

    private func reencode() {
        guard let data = sourceData else { return }
        let fit = fit
        isDecoding = true
        decodeError = nil
        Task {
            let result = await Task.detached(priority: .userInitiated) { () -> Result<([DisplayEncoder.Frame], Int), Error> in
                Result {
                    let count = CGImageSourceCreateWithData(data as CFData, nil).map(CGImageSourceGetCount) ?? 0
                    return (try DisplayEncoder.frames(from: data, fit: fit), count)
                }
            }.value
            isDecoding = false
            switch result {
            case .success(let (decoded, count)):
                frames = decoded
                sourceFrameCount = count
            case .failure(let error):
                frames = []
                decodeError = error.localizedDescription
            }
        }
    }

    private func clear() {
        sourceData = nil
        frames = []
        fileName = nil
        decodeError = nil
        store.control.clearUploadStatus()
    }

    private func upload() async {
        let success = await store.control.uploadScreen(frames)
        toasts.show(success
            ? Toast(.success, "Screen updated", message: fileName)
            : Toast(.error, "Upload didn't finish"))
    }
}

/// Plays fitted frames at their own delays, with crisp pixel scaling.
private struct AnimatedFramesView: View {
    let frames: [DisplayEncoder.Frame]

    var body: some View {
        let total = max(1, frames.reduce(0) { $0 + max($1.delayMilliseconds, 30) })
        TimelineView(.animation(minimumInterval: 1.0 / 30, paused: frames.count < 2)) { timeline in
            let elapsed = Int(timeline.date.timeIntervalSinceReferenceDate * 1000) % total
            Image(decorative: frame(at: elapsed), scale: 1)
                .resizable()
                .interpolation(.none)
        }
    }

    private func frame(at millisecond: Int) -> CGImage {
        var remaining = millisecond
        for frame in frames {
            remaining -= max(frame.delayMilliseconds, 30)
            if remaining < 0 { return frame.image }
        }
        return frames[0].image
    }
}
