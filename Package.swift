// swift-tools-version:5.9
import PackageDescription

let package = Package(
    name: "GlowAnimations",
    platforms: [
        .iOS(.v17)
    ],
    products: [
        .library(
            name: "GlowAnimations",
            targets: ["GlowAnimations"]
        ),
    ],
    dependencies: [],
    targets: [
        .target(
            name: "GlowAnimations",
            dependencies: [],
            path: "Sources",
            publicHeadersPath: nil
        ),
    ]
)
