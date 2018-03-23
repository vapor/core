public struct CoreError: Debuggable, Error {
    public var identifier: String
    public var reason: String
    public init(identifier: String, reason: String) {
        self.identifier = identifier
        self.reason = reason
    }
}
