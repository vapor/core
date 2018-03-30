import Debugging

/// Errors that can be thrown while working with Bits.
public struct BitsError: Debuggable {
    /// See `Debuggable`
    public var identifier: String

    /// See `Debuggable`
    public var reason: String

    /// See `Debuggable`
    public var possibleCauses: [String]

    /// See `Debuggable`
    public var suggestedFixes: [String]

    /// See `Debuggable`
    public var stackTrace: [String]?

    /// Creates a new `BitsError`.
    ///
    /// See `Debuggable`
    init(identifier: String, reason: String, suggestedFixes: [String] = [], possibleCauses: [String] = []) {
        self.identifier = identifier
        self.reason = reason
        self.suggestedFixes = suggestedFixes
        self.possibleCauses = possibleCauses
        self.stackTrace = BitsError.makeStackTrace()
    }
}

/// Logs an unhandleable runtime error.
internal func ERROR(_ string: @autoclosure () -> String) {
    print("[ERROR] [Bits] \(string())")
}
