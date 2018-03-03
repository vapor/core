// swift-tools-version:4.0
import PackageDescription

let package = Package(
    name: "Core",
    products: [
        .library(name: "Async", targets: ["Async"]),
        .library(name: "Bits", targets: ["Bits"]),
        .library(name: "CodableKit", targets: ["CodableKit"]),
        .library(name: "COperatingSystem", targets: ["COperatingSystem"]),
        .library(name: "Debugging", targets: ["Debugging"]),
    ],
    dependencies: [
        // Event-driven network application framework for high performance protocol servers & clients, non-blocking.
        .package(url: "https://github.com/apple/swift-nio.git", from: "1.0.0"),
    ],
    targets: [
        .target(name: "Async", dependencies: ["NIO"]),
        .target(name: "Bits", dependencies: ["NIO"]),
        .target(name: "CodableKit", dependencies: ["Async", "Debugging"]),
        .testTarget(name: "CodableKitTests", dependencies: ["CodableKit"]),
        .target(name: "COperatingSystem"),
        .target(name: "Debugging"),
        .testTarget(name: "DebuggingTests", dependencies: ["Debugging"]),
    ]
)
