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
            // create queue for async work
            
            // create process data pipes
            let stdout = Pipe()
            let stderr = Pipe()

            // setup dispatch io for stdout
            let stdoutPromise = worker.eventLoop.newPromise(Void.self)
            let stdoutIO = DispatchIO(type: .stream, fileDescriptor: stdout.fileHandleForReading.fileDescriptor, queue: executeQueue) { _ in
                close(stdout.fileHandleForReading.fileDescriptor)
            }
            stdoutIO.read(offset: 0, length: .max, queue: executeQueue) { done, data, err in
                if done {
                    stdoutPromise.succeed(result: ())
                } else if err != 0 {
                    stdoutPromise.fail(error: ProcessIOError(code: err))
                } else if let data = data, !data.isEmpty {
                    output(.stdout(Data(data)))
                }
            }
            
            // setup dispatch io for stderr
            let stderrPromise = worker.eventLoop.newPromise(Void.self)
            let stderrIO = DispatchIO(type: .stream, fileDescriptor: stderr.fileHandleForReading.fileDescriptor, queue: executeQueue) { _ in
                close(stderr.fileHandleForReading.fileDescriptor)
            }
            stderrIO.read(offset: 0, length: .max, queue: executeQueue) { done, data, err in
                if done {
                    stderrPromise.succeed(result: ())
                } else if err != 0 {
                    stderrPromise.fail(error: ProcessIOError(code: err))
                } else if let data = data, !data.isEmpty {
                    output(.stderr(Data(data)))
                }
            }

            // launch and run the process
            let process = launchProcess(path: program, arguments, stdout: stdout, stderr: stderr)

            // create a new promise for the termination status and set callback
            let processPromise = worker.eventLoop.newPromise(Int32.self)
            process.terminationHandler = { process in
                // complete the promise
                processPromise.succeed(result: process.terminationStatus)
            }

            return stdoutPromise.futureResult.and(stderrPromise.futureResult)
                .transform(to: processPromise.futureResult)
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

private struct ProcessIOError: Error {
    var code: Int32
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

private let executeQueue = DispatchQueue(label: "codes.vapor.core.async.execute")

#endif
