import PackageDescription

let package = Package(
    targets: [
        Target(name: "Core", dependencies: ["libc"]),
		Target(name: "libc")
	],
    name: "Core"
)
