// swift-tools-version:4.0
import PackageDescription

let package = Package(
    name: "Core",
    products: [
        .library(name: "libc", targets: ["libc"]),
        .library(name: "Core", targets: ["Core"]),
    ],
    dependencies: [
        .package(url: "https://github.com/vapor/debugging.git", .branch("beta")),
    ],
    targets: [
        .target(name: "libc"),
        .target(name: "Core", dependencies: ["libc", "Debugging"]),
        .testTarget(name: "CoreTests", dependencies: ["Core"]),
    ]
)
