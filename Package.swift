import PackageDescription

let package = Package(
    name: "Core",
    targets: [
        Target(name: "Core", dependencies: ["libc"]),
        Target(name: "libc")
    ],
    dependencies: [
        .Package(url: "https://github.com/vapor/bits.git", majorVersion: 0, minor: 1),
        .Package(url: "https://github.com/vapor/debugging.git", majorVersion: 0),
    ]
)
