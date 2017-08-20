/// A basic stream implementation that maps input
/// through a closure.
public final class MapStream<In, Out>: Stream {
    /// See InputStream.Input
    public typealias Input = In

    /// See OutputStream.Output
    public typealias Output = Out

    /// See OutputStream.outputStream
    public var outputStream: OutputHandler?

    /// See BaseStream.errorStream
    public var errorStream: ErrorHandler?

    /// Maps input to output
    public typealias MapClosure = (In) throws -> (Out)

    /// The stored map closure
    public let map: MapClosure

    /// Create a new Map stream with the supplied closure.
    public init(map: @escaping MapClosure) {
        self.map = map
    }

    /// See InputStream.inputStream
    public func inputStream(_ input: In) {
        do {
            let output = try map(input)
            outputStream?(output)
        } catch {
            errorStream?(error)
        }
    }
}
