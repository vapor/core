/// This protocol allows for reflection of properties on conforming types.
///
/// Ideally Swift type mirroring would handle this completely. In the interim, this protocol
/// acts to fill in the missing gaps.
///
/// Types that conform to this protocol and are also `Decodable` will get the implementations for free
/// from the `CodableKit` module.
public protocol Reflectable {
    /// Reflects all of this type's `ReflectedProperty`s.
    ///
    /// - parameter depth: Controls how deeply to reflect the properties.
    ///                    Each `ReflectedProperty` has a `[String]` path.
    ///                    The depth supplied here is a maximum for the depth of the properties.
    static func reflectProperties(depth: Int) throws -> [ReflectedProperty]

    /// Returns a `ReflectedProperty` for the supplied key path.
    static func reflectProperty<T>(forKey keyPath: KeyPath<Self, T>) throws -> ReflectedProperty
}

extension Reflectable {
    /// Reflects all of this type's `ReflectedProperty`s with depth = 1.
    public static func reflectProperties() throws -> [ReflectedProperty] {
        return try reflectProperties(depth: 1)
    }
}


/// Represents a property on a type that has been refleted using the `Reflectable` protocol.
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

extension ReflectedProperty: CustomStringConvertible {
    /// See CustomStringConvertible.description
    public var description: String {
        return "\(path.joined(separator: ".")): \(type)"
    }
}
