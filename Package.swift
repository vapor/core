import PackageDescription

let beta1 = Version(1,0,0, prereleaseIdentifiers: ["beta1"])

let package = Package(
    name: "Core",
    targets: [
        Target(name: "Core", dependencies: ["libc"]),
        Target(name: "libc")
    ],
    dependencies: [
        .Package(url: "https://github.com/vapor/bits.git", beta1),
        .Package(url: "https://github.com/vapor/debugging.git", beta1),
    ]
)
