// swift-tools-version:4.0
import PackageDescription

let package = Package(
    name: "Core",
    products: [
        .library(name: "libc", targets: ["libc"]),
    ],
    targets: [
        .target(name: "libc"),
    ]
)
