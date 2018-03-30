/// An encoder that is capable of handling `Future` encodable objects.
public protocol FutureEncoder: class {
    /// Encodes a `Future<Encodable>` object.
    func encodeFuture<E>(_ future: Future<E>) throws
        where E: Encodable
}

/// Conforms future to `Encodable` where its expectation is also `Encodable`.
extension Future: Encodable where T: Encodable {
    /// See `Encodable`.
    public func encode(to encoder: Encoder) throws {
        if let encoder = encoder as? FutureEncoder {
            try encoder.encodeFuture(self)
        }
    }
}
