public final class Promise<Expectation> {
    /// This promise's future.
    public let future: Future<Expectation>

    /// Create a new promise.
    public init(_ expectation: Expectation.Type = Expectation.self) {
        future = .init()
    }

    /// Fail to fulfill the promise.
    /// If the promise has already been fulfilled,
    /// it will quiety ignore the input.
    public func complete(_ error: Error) {
        guard !future.isCompleted else {
            return
        }
        
        future.error = error
        future.complete()
    }

    /// Fulfills the promise.
    /// If the promise has already been fulfilled,
    /// it will quiety ignore the input.
    public func complete(_ expectation: Expectation) {
        guard !future.isCompleted else {
            return
        }
        
        future.expectation = expectation
        future.complete()
    }

    /// Fulfills the promise.
    /// If the promise has already been fulfilled,
    /// it will quiety ignore the input.
    public func complete(_ closure: () throws -> (Expectation)) {
        guard !future.isCompleted else {
            return
        }
        
        do {
            future.expectation = try closure()
        } catch {
            future.error = error
        }
        
        future.complete()
    }
}
