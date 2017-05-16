import PackageDescription

let package = Package(
    name: "Core",
    targets: [
        Target(name: "Core", dependencies: ["libc"]),
        Target(name: "libc")
    ],
    dependencies: [
        .Package(url: "https://github.com/vapor/bits.git", majorVersion: 2),
        .Package(url: "https://github.com/vapor/debugging.git", majorVersion: 2),
    ]
)
