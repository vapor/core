/// A basic output stream.
public final class EmitterStream<Out>: OutputStream {
    /// See OutputStream.Output
    public typealias Output = Out

    /// See OutputStream.outputStream
    public var outputStream: OutputHandler?

    /// See BaseStream.errorStream
    public var errorStream: ErrorHandler?

    /// Create a new emitter stream.
    public init(_ type: Out.Type = Out.self) { }

    /// Emits an output.
    public func emit(_ output: Output) {
        outputStream?(output)
    }

    /// Emits an error.
    public func report(_ error: Error) {
        errorStream?(error)
    }
}
