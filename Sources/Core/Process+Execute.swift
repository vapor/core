#if !os(iOS)

extension Process {
    /// Executes the supplied program in a new process, blocking until the process completes.
    /// Any data piped to `stdout` during the process will be returned as a string.
    /// If the process exits with a non-zero status code, an error will be thrown containing
    /// the contents of `stderr` and `stdout`.
    ///
    ///     let result = try Process.execute("echo", "hi")
    ///     print(result) /// "hi"
    ///
    /// - parameters:
    ///     - program: The name of the program to execute. If it does not begin with a `/`, the full
    ///                path will be resolved using `/bin/sh -c which ...`.
    ///     - arguments: An array of arguments to pass to the program.
    public static func execute(_ program: String, _ arguments: String...) throws -> String {
        return try execute(program, arguments)
    }

    /// Executes the supplied program in a new process, blocking until the process completes.
    /// Any data piped to `stdout` during the process will be returned as a string.
    /// If the process exits with a non-zero status code, an error will be thrown containing
    /// the contents of `stderr` and `stdout`.
    ///
    ///     let result = try Process.execute("echo", "hi")
    ///     print(result) /// "hi"
    ///
    /// - parameters:
    ///     - program: The name of the program to execute. If it does not begin with a `/`, the full
    ///                path will be resolved using `/bin/sh -c which ...`.
    ///     - arguments: An array of arguments to pass to the program.
    public static func execute(_ program: String, _ arguments: [String]) throws -> String {
        if program.hasPrefix("/") {
            return try launchAndWait(launchPath: program, arguments)
        } else {
            guard let resolvedPath = try? launchAndWait(launchPath: "/bin/sh", ["-c", "which \(program)"]) else {
                throw CoreError(identifier: "executablePath", reason: "Could not find executable path for program: \(program).")
            }
            return try launchAndWait(launchPath: resolvedPath, arguments)
        }
    }

    /// Powers `Process.execute(_:_:)` methods. Separated so that `/bin/sh -c which` can run as a separate command.
    private static func launchAndWait(launchPath: String, _ arguments: [String]) throws -> String {
        let stdout = Pipe()
        let stderr = Pipe()

        let process = Process()
        process.environment = ProcessInfo.processInfo.environment
        process.launchPath = launchPath
        process.arguments = arguments
        process.standardOutput = stdout
        process.standardError = stderr

        process.launch()
        process.waitUntilExit()

        guard process.terminationStatus == 0 else {
            throw try ProcessExecuteError(
                status: process.terminationStatus,
                stderr: stderr.readString(),
                stdout: stdout.readString()
            )
        }

        return try stdout.readString()
    }
}

/// An error that can be thrown while using `Process.execute(_:_:)`
public struct ProcessExecuteError: Error {
    /// The exit status
    public let status: Int32

    /// Contents of `stderr`
    public var stderr: String

    /// Contents of `stdout`
    public var stdout: String
}

extension ProcessExecuteError: Debuggable {
    /// See `Debuggable.identifier`.
    public var identifier: String {
        return status.description
    }

    /// See `Debuggable.reason`
    public var reason: String {
        return stderr
    }
}

extension Pipe {
    /// Reads the contents of a pipe and converts to a `String`.
    fileprivate func readString(encoding: String.Encoding = .utf8) throws -> String {
        guard let string = String(data: fileHandleForReading.readDataToEndOfFile(), encoding: encoding) else {
            return ""
        }
        return string.trimmingCharacters(in: .whitespacesAndNewlines)
    }
}

#endif
