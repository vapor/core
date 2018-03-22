/// A property from a Decodable type.
public struct CodableProperty {
    /// This property's type.
    public let type: Any.Type

    /// The coding path to this property.
    public let path: [String]

    /// Creates a new `CodingKeyProperty` from a type.
    public init<T>(_ type: T.Type, at path: [String]) {
        self.type = T.self
        self.path = path
    }

    /// Creates a new `CodingKeyProperty` using `Any.Type`.
    public init(any type: Any.Type, at path: [String]) {
        self.type = type
        self.path = path
    }
}

extension CodableProperty: CustomStringConvertible {
    /// See CustomStringConvertible.description
    public var description: String {
        return "\(path.joined(separator: ".")): \(type)"
    }
}
