// swift-tools-version: 6.0
import PackageDescription

let package = Package(
    name: "AULAStudio",
    defaultLocalization: "en",
    platforms: [.macOS(.v15)],
    products: [
        .executable(name: "AULAStudio", targets: ["AULAStudio"]),
        .executable(name: "aulactl", targets: ["aulactl"]),
        .library(name: "AulaKit", targets: ["AulaKit"]),
        .library(name: "AulaDesignSystem", targets: ["AulaDesignSystem"]),
    ],
    targets: [
        // Hardware + domain layer. No SwiftUI. Everything here is unit-testable.
        .target(name: "AulaKit"),

        // Tokens + reusable SwiftUI components. Knows nothing about keyboards.
        .target(name: "AulaDesignSystem"),

        // The app: shell, features, menu bar, settings.
        .executableTarget(
            name: "AULAStudio",
            dependencies: ["AulaKit", "AulaDesignSystem"]
        ),

        // Developer CLI for HID diagnostics and protocol work.
        .executableTarget(name: "aulactl", dependencies: ["AulaKit"]),

        .testTarget(name: "AulaKitTests", dependencies: ["AulaKit"]),
        .testTarget(name: "AulaDesignSystemTests", dependencies: ["AulaDesignSystem"]),
    ]
)
