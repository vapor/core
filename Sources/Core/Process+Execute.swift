#if !os(iOS)
import NIO

/// Different types of process output.
public enum ProcessOutput {
    /// Standard process output.
    case stdout(Data)

    /// Standard process error output.
    case stderr(Data)
}

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
        var stderr: String = ""
        var stdout: String = ""
        let status = try asyncExecute(program, arguments, on: EmbeddedEventLoop()) { output in
            switch output {
            case .stderr(let data):
                stderr += String(data: data, encoding: .utf8) ?? ""
            case .stdout(let data):
                stdout += String(data: data, encoding: .utf8) ?? ""
            }
        }.wait()
        if status != 0 {
            throw ProcessExecuteError(status: status, stderr: stderr, stdout: stdout)
        }
        return stdout.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    /// Asynchronously the supplied program in a new process. Stderr and stdout will be supplied to the output closure
    /// as it is received. The returned future will finish when the process has terminated.
    ///
    ///     let status = try Process.asyncExecute("echo", "hi", on: ...) { output in
    ///         print(output)
    ///     }.wait()
    ///     print(result) // 0
    ///
    /// - parameters:
    ///     - program: The name of the program to execute. If it does not begin with a `/`, the full
    ///                path will be resolved using `/bin/sh -c which ...`.
    ///     - arguments: An array of arguments to pass to the program.
    ///     - worker: Worker to perform async task on.
    ///     - output: Handler for the process output.
    /// - returns: A future containing the termination status of the process.
    public static func asyncExecute(_ program: String, _ arguments: String..., on worker: Worker, _ output: @escaping (ProcessOutput) -> ()) -> Future<Int32> {
        return asyncExecute(program, arguments, on: worker, output)
    }

    /// Asynchronously the supplied program in a new process. Stderr and stdout will be supplied to the output closure
    /// as it is received. The returned future will finish when the process has terminated.
    ///
    ///     let status = try Process.asyncExecute("echo", ["hi"], on: ...) { output in
    ///         print(output)
    ///     }.wait()
    ///     print(result) // 0
    ///
    /// - parameters:
    ///     - program: The name of the program to execute. If it does not begin with a `/`, the full
    ///                path will be resolved using `/bin/sh -c which ...`.
    ///     - arguments: An array of arguments to pass to the program.
    ///     - worker: Worker to perform async task on.
    ///     - output: Handler for the process output.
    /// - returns: A future containing the termination status of the process.
    public static func asyncExecute(_ program: String, _ arguments: [String], on worker: Worker, _ output: @escaping (ProcessOutput) -> ()) -> Future<Int32> {
        if program.hasPrefix("/") {
            // create process data pipes
            let stdout = Pipe()
            let stderr = Pipe()
            
            // create dispatch sources for the pipes
            let stdoutsource = DispatchSource.makeReadSource(fileDescriptor: stdout.fileHandleForReading.fileDescriptor)
            let stderrsource = DispatchSource.makeReadSource(fileDescriptor: stderr.fileHandleForReading.fileDescriptor)
            
            // setup read handlers for the output sources
            stdoutsource.setEventHandler {
                 let data = stdout.fileHandleForReading.availableData
                 guard !data.isEmpty else {
                     return
                 }
                 output(.stdout(data))
            }
            stderrsource.setEventHandler {
                let data = stderr.fileHandleForReading.availableData
                guard !data.isEmpty else {
                    return
                }
                output(.stderr(data))
            }
        
            // start the output sources
            stdoutsource.resume()
            stderrsource.resume()
            
            // launch and run the process
            let process = launchProcess(path: program, arguments, stdout: stdout, stderr: stderr)
            
            // succeed with the termination status
            let promise = worker.eventLoop.newPromise(Int32.self)
            process.terminationHandler = { process in
                // cleanup output sources
                stdoutsource.cancel()
                stderrsource.cancel()
                
                // complete the promise
                promise.succeed(result: process.terminationStatus)
            }

            return promise.futureResult
        } else {
            var resolvedPath: String?
            return asyncExecute("/bin/sh", ["-c", "which \(program)"], on: worker) { o in
                switch o {
                case .stdout(let data): resolvedPath = String(data: data, encoding: .utf8)?
                    .trimmingCharacters(in: .whitespacesAndNewlines)
                default: break
                }
            }.flatMap { status in
                guard let path = resolvedPath, path.hasPrefix("/") else {
                    throw CoreError(identifier: "executablePath", reason: "Could not find executable path for program: \(program).")
                }
                return asyncExecute(path, arguments, on: worker, output)
            }
        }
    }

    /// Powers `Process.execute(_:_:)` methods. Separated so that `/bin/sh -c which` can run as a separate command.
    private static func launchProcess(path: String, _ arguments: [String], stdout: Pipe, stderr: Pipe) -> Process {
        let process = Process()
        process.environment = ProcessInfo.processInfo.environment
        process.launchPath = path
        process.arguments = arguments
        process.standardOutput = stdout
        process.standardError = stderr
        process.launch()
        return process
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

#endif
