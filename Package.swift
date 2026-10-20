// swift-tools-version: 6.0
import PackageDescription

let package = Package(
    name: "ProResDrop",
    defaultLocalization: "de",
    platforms: [.macOS(.v14)],
    products: [
        .executable(name: "ProResDrop", targets: ["ProResDrop"]),
        .executable(name: "prores-drop-cli", targets: ["prores-drop-cli"]),
    ],
    targets: [
        // The encode itself: plan, transcoder, names, messages. No UI, so the CLI and the tests
        // run exactly what the app runs.
        .target(name: "DropCore", swiftSettings: [.swiftLanguageMode(.v5)]),
        .executableTarget(name: "ProResDrop", dependencies: ["DropCore"],
                          swiftSettings: [.swiftLanguageMode(.v5)]),
        .executableTarget(name: "prores-drop-cli", dependencies: ["DropCore"],
                          swiftSettings: [.swiftLanguageMode(.v5)]),
        .testTarget(name: "DropCoreTests", dependencies: ["DropCore"],
                    resources: [.copy("fixtures")],
                    swiftSettings: [.swiftLanguageMode(.v5)]),
    ]
)
