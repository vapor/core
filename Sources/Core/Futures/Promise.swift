/// Promises are used to create futures.
/// The promise is the only object that can
/// complete the future it created.
///
/// Note: completing a promise and awaiting
/// the promise's future _must_ be done on the
/// same dispatch queue.
///
/// There is no internal locking or synchronizing.
/// (except in the case of a future's awaiter that has
/// requested to be notified on a different queue)
public final class Promise<T> {
    /// This promise's future.
    public let future: Future<T>

    /// Create a new promise.
    public init(_ expectation: T.Type = T.self) {
        future = .init()
    }

    /// Fail to fulfill the promise.
    /// If the promise has already been fulfilled,
    /// it will quiety ignore the input.
    public func fail(_ error: Error) {
        future.complete(with: .error(error))
    }

    /// Fulfills the promise.
    /// If the promise has already been fulfilled,
    /// it will quiety ignore the input.
    public func complete(_ expectation: T) {
        future.complete(with: .expectation(expectation))
    }
}
