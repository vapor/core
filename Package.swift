import PackageDescription

var dependencies: [Package.Dependency] = []

#if os(Linux)
    dependencies += [
        //Wrapper around pthreads
        .Package(url: "https://github.com/ketzusaka/Strand.git", majorVersion: 1, minor: 5)
    ]
#endif

let package = Package(
    name: "Core",
    targets: [
        Target(name: "Core", dependencies: ["libc"]),
		Target(name: "libc")
	],
    dependencies: dependencies
)
