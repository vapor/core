public struct StringKey {
    let string: String
    public init(_ string: String) {
        self.string = string
    }
}

extension StringKey: CodingKey {
    public var stringValue: String {
        return string
    }

    public var intValue: Int? {
        return string.int
    }

    public init?(stringValue: String) {
        self.string = stringValue
    }

    public init?(intValue: Int) {
        self.string = intValue.description
    }
}
