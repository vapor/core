import COperatingSystem

/// `DirectoryConfig` represents a configured working directory. It can also be used to derive a working directory automatically.
///
///     let dirConfig = DirectoryConfig.detect()
///     print(dirConfig.workDir) // "/path/to/workdir"
///
public struct DirectoryConfig {
    /// Path to the current working directory.
    public let workDir: String

    /// Create a new `DirectoryConfig` with a custom working directory.
    ///
    /// - parameters:
    ///     - workDir: Custom working directory path.
    public init(workDir: String) {
        self.workDir = workDir
    }

    /// Creates a `DirectoryConfig` by deriving a working directory using the `#file` variable or `getcwd` method.
    ///
    /// - returns: The derived `DirectoryConfig` if it could be created, otherwise just "./".
    public static func detect() -> DirectoryConfig {
        var workDir: String

        let cwd = getcwd(nil, Int(PATH_MAX))
        defer {
            free(cwd)
        }
        if let cwd = cwd, let string = String(validatingUTF8: cwd) {
            workDir = string
        } else {
            workDir = "./"
        }

        let standardPaths = [".build", "Packages", "Sources"]
        for path in standardPaths {
            if workDir.contains(path){
                workDir = workDir.components(separatedBy:"/\(path)").first!
                break
            }
        }

        return DirectoryConfig(
            workDir: workDir.hasSuffix("/") ? workDir : workDir + "/"
        )
    }
}
