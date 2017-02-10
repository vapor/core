import PackageDescription

let package = Package(
    name: "Core",
    targets: [
        Target(name: "Core", dependencies: ["libc"]),
        Target(name: "libc")
    ],
    dependencies: [
        .Package(url: "https://github.com/vapor/bits.git", Version(0,1,0))
    ]
)
