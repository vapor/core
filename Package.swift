// swift-tools-version:3.0
import PackageDescription

let package = Package(
    name: "Core",
    targets: [
        Target(name: "Core", dependencies: ["libc"]),
        Target(name: "libc")
    ],
    dependencies: [
        .Package(url: "https://github.com/vapor/bits.git", majorVersion: 1),
        .Package(url: "https://github.com/vapor/debugging.git", majorVersion: 1),
    ]
)
