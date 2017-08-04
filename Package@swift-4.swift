// swift-tools-version:4.0
import PackageDescription

let package = Package(
    name: "Core",
    products: [
        .library(name: "libc", targets: ["libc"]),
        .library(name: "Core", targets: ["Core"]),
    ],
    dependencies: [
        .package(url: "https://github.com/vapor/bits.git", .upToNextMajor(from: "1.1.0"),
        .package(url: "https://github.com/vapor/debugging.git", .upToNextMajor(from: "1.1.0"),
    ],
    targets: [
        .target(name: "libc"),
        .target(name: "Core", dependencies: ["libc", "Bits", "Debugging"]),
        .testTarget(name: "CoreTests", dependencies: ["Core"]),
    ]
)
