public final class EmitterStream<Out>: OutputStream {
    public typealias Output = Out

    public var outputStream: OutputHandler?
    public var errorStream: ErrorHandler?

    public init() { }

    public func emit(_ output: Output) {
        outputStream?(output)
    }

    public func report(_ error: Error) {
        errorStream?(error)
    }
}
