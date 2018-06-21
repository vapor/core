/// Generic "not found" error with optional root cause.
///
///     throw NotFound(rootCause: ...)
///
public struct NotFound: Error {
    /// Underlying error that led to the `NotFound` error being thrown.
    public let rootCause: Error?
    
    /// Creates a new `NotFound` error.
    ///
    ///     throw NotFound(rootCause: ...)
    ///
    /// - parameters:
    ///     - rootCause: Underlying error that led to the `NotFound` error being thrown.
    public init(rootCause: Error? = nil) {
        self.rootCause = rootCause
    }
}
