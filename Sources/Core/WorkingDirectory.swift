/// This function will attempt to get the current
/// working directory of the application
public func workingDirectory() -> String {
    let file = #file
    let directory: String?
    if file.contains(".build") {
        directory = file.components(separatedBy: "/.build").first
    } else {
        directory = file.components(separatedBy: "/Sources").first
    }
    return directory?.finished(with: "/") ?? "./"
}
