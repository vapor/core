public struct CoreError: Debuggable, Error {
    public var identifier: String
    public var reason: String
    public var suggestedFixes: [String]
    public var possibleCauses: [String]
    public init(identifier: String, reason: String, suggestedFixes: [String] = [], possibleCauses: [String] = []) {
        self.identifier = identifier
        self.reason = reason
        self.suggestedFixes = suggestedFixes
        self.possibleCauses = possibleCauses
    }
}
