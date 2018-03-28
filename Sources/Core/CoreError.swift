public struct CoreError: Debuggable, Error {
    public var identifier: String
    public var reason: String
    public var possibleCauses: [String]
    public var suggestedFixes: [String]
    public init(identifier: String, reason: String, possibleCauses: [String] = [], suggestedFixes: [String] = []) {
        self.identifier = identifier
        self.reason = reason
        self.suggestedFixes = suggestedFixes
        self.possibleCauses = possibleCauses
    }
}
