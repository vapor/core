import Debugging
import COperatingSystem

/// Errors that can be thrown while working with TCP sockets.
public struct FileError: Debuggable {
    public static let readableName = "TCP Error"
    public let identifier: String
    public var reason: String
    public var sourceLocation: SourceLocation?
    public var stackTrace: [String]
    public var possibleCauses: [String]
    public var suggestedFixes: [String]
    
    /// Create a new TCP error.
    public init(
        identifier: String,
        reason: String,
        possibleCauses: [String] = [],
        suggestedFixes: [String] = [],
        sourceLocation: SourceLocation
    ) {
        self.identifier = identifier
        self.reason = reason
        self.sourceLocation = sourceLocation
        self.stackTrace = FileError.makeStackTrace()
        self.possibleCauses = possibleCauses
        self.suggestedFixes = suggestedFixes
    }
    
    /// Create a new TCP error from a POSIX errno.
    static func posix(
        _ errno: Int32,
        identifier: String,
        possibleCauses: [String] = [],
        suggestedFixes: [String] = [],
        sourceLocation: SourceLocation
    ) -> FileError {
        let message = COperatingSystem.strerror(errno)
        let string = String(cString: message!, encoding: .utf8) ?? "unknown"
        return FileError(
            identifier: identifier,
            reason: string,
            possibleCauses: possibleCauses,
            suggestedFixes: suggestedFixes,
            sourceLocation: sourceLocation
        )
    }
}



