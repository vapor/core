import Asyncgit	

/// Capable of encoding streams.
public protocol StreamEncoder: class {
    /// Encodes a stream of encodables to the encoder.
    func encodeStream<O: OutputStream>(_ stream: O) throws where O.Output == Encodable
}

extension OutputStream where Output: Encodable {
    /// Transforms this OutputStream to an encodable stream
    public var encodableStream: EncodableStream {
        return EncodableStream(self)
    }
}

extension OutputStream where Output == Encodable {
    /// Transforms this OutputStream to an encodable stream
    public var encodableStream: EncodableStream {
        return EncodableStream(self)
    }
}

/// A wrapper around an Encodable stream
public final class EncodableStream: OutputStream, Encodable {
    public typealias Output = Encodable
    
    /// The wrapped stream
    let stream: AnyOutputStream<Encodable>
    
    /// Creates a new EncodableStream from an existing OutputStream containing Encodables
    public init<S: OutputStream>(_ wrapped: S) where S.Output: Encodable {
        self.stream = AnyOutputStream(wrapped.map(to: Encodable.self) { $0 })
    }
    
    /// Creates a new EncodableStream from an existing OutputStream containing Encodables
    public init<S: OutputStream>(_ wrapped: S) where S.Output == Encodable {
        self.stream = AnyOutputStream(wrapped.map(to: Encodable.self) { $0 })
    }
    
    /// See `OutputStream.output`
    public func output<S>(to inputStream: S) where S : InputStream, EncodableStream.Output == S.Input {
        stream.output(to: inputStream)
    }
    
    /// Encodes this OutputStream to a StreamEncoder
    public func encode(to encoder: Encoder) throws {
        if let encoder = encoder as? StreamEncoder {
            try encoder.encodeStream(stream)
        }
    }
}

