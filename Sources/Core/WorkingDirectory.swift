import libc

private let defaultCwd: String = {
    let file = #file
    let directory: String?

    if file.contains(".build") {
        // most dependencies are in `./.build/`
        directory = file.components(separatedBy: "/.build").first
    } else if file.contains("Packages") {
        // when editing a dependency, it is in `./Packages/`
        directory = file.components(separatedBy: "/Packages").first
    } else {
        // when dealing with current repository, file is in `./Sources/`
        directory = file.components(separatedBy: "/Sources").first
    }

    return directory?.finished(with: "/") ?? "./"
}()

/// This function will attempt to get the current
/// working directory of the application
public func workingDirectory() -> String {
    guard let cwd = getcwd(nil, Int(PATH_MAX)) else {
        return defaultCwd
    }
    
    defer {
        free(cwd)
    }
    
    return String(validatingUTF8: cwd)?.finished(with: "/") ?? defaultCwd
}
