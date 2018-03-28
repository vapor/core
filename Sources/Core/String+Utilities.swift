extension String {
    /// Converts the string to a boolean or return nil.
    public var bool: Bool? {
        switch self {
        case "true", "yes", "1": return true
        case "false", "no", "0": return false
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
    public init?(_ string: String) {
        self.init(uuidString: string)
    }
}
