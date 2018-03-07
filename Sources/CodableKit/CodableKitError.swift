import Debugging
import Foundation

/// Errors that can be thrown while working with Codable Kit.
public struct CodableKitError: Debuggable {
    public static let readableName = "Codable Kit Error"
    public let identifier: String
    public var reason: String
    public var sourceLocation: SourceLocation?
    public var stackTrace: [String]
    public var suggestedFixes: [String]
    public var possibleCauses: [String]

    init(
        identifier: String,
        reason: String,
        suggestedFixes: [String] = [],
        possibleCauses: [String] = [],
        source: SourceLocation
    ) {
        self.identifier = identifier
        self.reason = reason
        self.suggestedFixes = suggestedFixes
        self.possibleCauses = possibleCauses
        self.sourceLocation = source
        self.stackTrace = CodableKitError.makeStackTrace()
    }
}

