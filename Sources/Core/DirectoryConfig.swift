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
        var fileBasedWorkDir: String? = nil

        #if Xcode
        // check if we are in Xcode via SPM integration
        if !#file.contains("SourcePackages/checkouts") {
            // we are NOT in Xcode via SPM integration
            // use #file hacks to determine working directory automatically
            if #file.contains(".build") {
                // most dependencies are in `./.build/`
                fileBasedWorkDir = #file.components(separatedBy: "/.build").first
            } else if #file.contains("Packages") {
                // when editing a dependency, it is in `./Packages/`
                fileBasedWorkDir = #file.components(separatedBy: "/Packages").first
            } else {
                // when dealing with current repository, file is in `./Sources/`
                fileBasedWorkDir = #file.components(separatedBy: "/Sources").first
            }
        }
        #endif

        let workDir: String
        if let fileBasedWorkDir = fileBasedWorkDir {
            workDir = fileBasedWorkDir
        } else {
            // get actual working directory
            let cwd = getcwd(nil, Int(PATH_MAX))
            defer {
                free(cwd)
            }

            if let cwd = cwd, let string = String(validatingUTF8: cwd) {
                workDir = string
            } else {
                workDir = "./"
            }
        }

        return DirectoryConfig(
            workDir: workDir.hasSuffix("/") ? workDir : workDir + "/"
        )
    }
}
