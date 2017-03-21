/// This function will attempt to get the current
/// working directory of the application
public func workingDirectory() -> String {
    let file = #file
    let directory: String?
    // most dependencies are in `./.build/`
    if file.contains(".build") {
        directory = file.components(separatedBy: "/.build").first
    // when editing a dependency, it is in `./Packages/`
    } else if file.contains("Packages") {
        directory = file.components(separatedBy: "/Packages").first
    // when dealing with current repository, file is in `./Sources/`
    } else {
        directory = file.components(separatedBy: "/Sources").first
    }
    return directory?.finished(with: "/") ?? "./"
}
