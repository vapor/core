// swift-tools-version:4.0
import PackageDescription

let package = Package(
    name: "Core",
    products: [
        .library(name: "Bits", targets: ["Bits"]),
        .library(name: "CodableKit", targets: ["CodableKit"]),
        .library(name: "COperatingSystem", targets: ["COperatingSystem"]),
        .library(name: "Debugging", targets: ["Debugging"]),
        .library(name: "Files", targets: ["Files"]),
    ],
    dependencies: [
        // Swift Promises, Futures, and Streams.
        .package(url: "https://github.com/vapor/async.git", .branch("beta")),
    ],
    targets: [
        .target(name: "Bits"),
        .target(name: "CodableKit", dependencies: ["Async", "Debugging"]),
        .target(name: "COperatingSystem"),
        .target(name: "Debugging"),
        .testTarget(name: "DebuggingTests", dependencies: ["Debugging"]),
        .target(name: "Files", dependencies: ["Async", "Debugging"]),
        .testTarget(name: "FilesTests", dependencies: ["Files"]),
    ]
)
