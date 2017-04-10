import PackageDescription

let beta = Version(1,0,0, prereleaseIdentifiers: ["beta"])

let package = Package(
    name: "Core",
    targets: [
        Target(name: "Core", dependencies: ["libc"]),
        Target(name: "libc")
    ],
    dependencies: [
        .Package(url: "https://github.com/vapor/bits.git", beta),
        .Package(url: "https://github.com/vapor/debugging.git", beta),
    ]
)
