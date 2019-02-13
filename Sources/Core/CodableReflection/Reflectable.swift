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
///         static func reflectProperty<T>(forKey keyPath: WritableKeyPath<User, T>) throws -> ReflectedProperty? {
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
    ///     - depth: The level of nesting to use.
    ///              If `0`, the top-most properties will be returned.
    ///              If `1`, the first layer of nested properties, and so-on.
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
    static func reflectProperty<T>(forKey keyPath: WritableKeyPath<Self, T>) throws -> ReflectedProperty?
        where T: ReflectionDecodable
}

extension Reflectable {
    /// Reflects all of this type's `ReflectedProperty`s.
    public static func reflectProperties() throws -> [ReflectedProperty] {
        return try reflectProperties(depth: 0)
    }
}
