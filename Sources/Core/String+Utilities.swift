extension String {
    /// Converts the string to a `Bool` or returns `nil`.
    public var bool: Bool? {
        switch self {
        case "true", "yes", "1", "y": return true
        case "false", "no", "0", "n": return false
        default: return nil
        }
    }
}

extension String {
    /// Ensures a string has a trailing suffix w/o duplicating
    ///
    ///     "hello.jpg".finished(with: ".jpg") // hello.jpg
    ///     "hello".finished(with: ".jpg") // hello.jpg
    ///
    public func finished(with end: String) -> String {
        guard !self.hasSuffix(end) else { return self }
        return self + end
    }
}

extension UUID: LosslessStringConvertible {
    /// See `LosslessStringConvertible`.
    public init?(_ string: String) {
        self.init(uuidString: string)
    }
}
