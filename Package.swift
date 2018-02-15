// swift-tools-version:4.0
import PackageDescription

let package = Package(
    name: "Core",
    products: [
        .library(name: "Bits", targets: ["Bits"]),
        .library(name: "CodableKit", targets: ["CodableKit"]),
        .library(name: "COperatingSystem", targets: ["COperatingSystem"]),
        .library(name: "Debugging", targets: ["Debugging"]),
    ],
    dependencies: [
        // Swift Promises, Futures, and Streams.
        .package(url: "https://github.com/vapor/async.git", "1.0.0-beta.1"..<"1.0.0-beta.2"),
    ],
    targets: [
        .target(name: "Bits"),
        .target(name: "CodableKit", dependencies: ["Async", "Debugging"]),
        .testTarget(name: "CodableKitTests", dependencies: ["CodableKit"]),
        .target(name: "COperatingSystem"),
        .target(name: "Debugging"),
        .testTarget(name: "DebuggingTests", dependencies: ["Debugging"]),
    ]
)
