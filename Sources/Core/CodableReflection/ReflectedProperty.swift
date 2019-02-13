/// Represents a property on a type that has been reflected using the `Reflectable` protocol.
///
///     let property = try User.reflectProperty(forKey: \.pet.name)
///     print(property) // ["pet", "name"] String
///
public struct ReflectedProperty {
    /// This property's type.
    public let type: Any.Type
    
    /// The path to this property.
    public let path: [String]
    
    /// Creates a new `ReflectedProperty` from a type and path.
    public init<T>(_ type: T.Type, at path: [String]) {
        self.type = T.self
        self.path = path
    }
    
    /// Creates a new `ReflectedProperty` using `Any.Type` and a path.
    public init(any type: Any.Type, at path: [String]) {
        self.type = type
        self.path = path
    }
}

extension Collection where Element == ReflectedProperty {
    /// Removes all optional properties from an array of `ReflectedProperty`.
    public func optionalsRemoved() -> [ReflectedProperty] {
        return filter { !($0.type is AnyOptionalType.Type) }
    }
}

extension ReflectedProperty: CustomStringConvertible {
    /// See `CustomStringConvertible`.
    public var description: String {
        return "\(path.joined(separator: ".")): \(type)"
    }
}
