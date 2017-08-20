/// A basic stream implementation that maps input
/// through a closure.
public final class MapStream<In, Out>: Stream {
    public typealias Input = In
    public typealias Output = Out

    public var outputStream: OutputHandler?
    public var errorStream: ErrorHandler?

    /// Maps input to output
    public typealias MapClosure = (In) throws -> (Out)

    /// The stored map closure
    public let map: MapClosure

    /// Create a new Map stream with the supplied closure.
    public init(map: @escaping MapClosure) {
        self.map = map
    }

    public func inputStream(_ input: In) {
        do {
            let output = try map(input)
            outputStream?(output)
        } catch {
            errorStream?(error)
        }
    }
}
