extension String {
    /// Attempts to convert the `String` to an `Array`.
    /// Comma separated items will be split into
    /// multiple entries.
    public func commaSeparatedArray() -> [String] {
        return characters
            .split(separator: ",")
            .map { String($0) }
            .map { $0.trimmedWhitespace() }
    }
}

extension String {
    fileprivate func trimmedWhitespace() -> String {
        var characters = self.characters

        while characters.first?.isWhitespace == true {
            characters.removeFirst()
        }
        while characters.last?.isWhitespace == true {
            characters.removeLast()
        }

        return String(characters)
    }
}

extension Character {
    fileprivate var isWhitespace: Bool {
        switch self {
        case " ", "\t", "\n", "\r":
            return true
        default:
            return false
        }
    }
}
