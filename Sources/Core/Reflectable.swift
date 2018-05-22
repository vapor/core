/// This protocol allows for reflection of properties on conforming types.
///
/// Ideally Swift type mirroring would handle this completely. In the interim, this protocol
/// acts to fill in the missing gaps.
///
///     struct Pet: Decodable {
///         var name: String
///         var age: Int
///     }
///
///     struct User: Reflectable, Decodable {
///         var id: UUID?
///         var name: String
///         var pet: Pet
///     }
///
///     try User.reflectProperties(depth: 0) // [id: UUID?, name: String, pet: Pet]
///     try User.reflectProperties(depth: 1) // [pet.name: String, pet.age: Int]
///     try User.reflectProperty(forKey: \.name) // ["name"] String
///     try User.reflectProperty(forKey: \.pet.name) // ["pet", "name"] String
///
/// Types that conform to this protocol and are also `Decodable` will get the implementations for free
/// using a decoder to discover the type's structure.
///
/// Any type can conform to `Reflectable` by implementing its two static methods.
///
///     struct User: Reflectable {
///         var firstName: String
///         var lastName: String
///
///         static func reflectProperties(depth: Int) throws -> [ReflectedProperty] {
///             guard depth == 0 else { return [] } // this type only has properties at depth 0
///             return [.init(String.self, at: ["first_name"]), .init(String.self, at: ["last_name"])]
///         }
///
///         static func reflectProperty<T>(forKey keyPath: KeyPath<User, T>) throws -> ReflectedProperty? {
///             let key: String
///             switch keyPath {
///             case \User.firstName: key = "first_name"
///             case \User.lastName: key = "last_name"
///             default: return nil
///             }
///             return .init(T.self, at: [key])
///         }
///     }
///
/// Even if your type gets the default implementation for being `Decodable`, you can still override both
/// the `reflectProperties(dpeth:)` and `reflectProperty(forKey:)` methods.
public protocol Reflectable {
    /// Reflects all of this type's `ReflectedProperty`s.
    ///
    ///     struct Pet: Decodable {
    ///         var name: String
    ///         var age: Int
    ///     }
    ///
    ///     struct User: Reflectable, Decodable {
    ///         var id: UUID?
    ///         var name: String
    ///         var pet: Pet
    ///     }
    ///
    ///     try User.reflectProperties(depth: 0) // [id: UUID?, name: String, pet: Pet]
    ///     try User.reflectProperties(depth: 1) // [pet.name: String, pet.age: Int]
    ///
    /// - parameters:
    /// 	- depth: The level of nesting to use.
    ///              	If `0`, the top-most properties will be returned.
    ///                 If `1`, the first layer of nested properties, and so-on.
    /// - throws: Any error reflecting this type's properties.
    /// - returns: All `ReflectedProperty`s at the specified depth.
    static func reflectProperties(depth: Int) throws -> [ReflectedProperty]

    /// Returns a `ReflectedProperty` for the supplied key path.
    ///
    ///     struct Pet: Decodable {
    ///         var name: String
    ///         var age: Int
    ///     }
    ///
    ///     struct User: Reflectable, Decodable {
    ///         var id: UUID?
    ///         var name: String
    ///         var pet: Pet
    ///     }
    ///
    ///     try User.reflectProperty(forKey: \.name) // ["name"] String
    ///     try User.reflectProperty(forKey: \.pet.name) // ["pet", "name"] String
    ///
    /// - parameters:
    ///     - keyPath: `KeyPath` to reflect a property for.
    /// - throws: Any error reflecting this property.
    /// - returns: `ReflectedProperty` if one was found.
    static func reflectProperty<T>(forKey keyPath: KeyPath<Self, T>) throws -> ReflectedProperty?
}

extension Reflectable {
    /// Reflects all of this type's `ReflectedProperty`s.
    /// - parameters:
    ///      - includeOptionals: Whether Optional properties should be included or not.
    public static func reflectProperties(includeOptionals: Bool = true) throws -> [ReflectedProperty] {
        if includeOptionals {
        	return try reflectProperties(depth: 0)
    	} else {
    		return try reflectProperties(depth: 0)
    			/// remove optionals
            	.filter({ !($0.type is AnyOptionalType.Type) })
    	}
    }
}

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

extension ReflectedProperty: CustomStringConvertible {
    /// See `CustomStringConvertible.description`
    public var description: String {
        return "\(path.joined(separator: ".")): \(type)"
    }
}
