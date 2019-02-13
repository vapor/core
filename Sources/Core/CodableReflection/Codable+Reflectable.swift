import Foundation

/// Default `Reflectable` implementation for types that are also `Decodable`.
extension Reflectable where Self: Decodable & Encodable {
    /// Default `Reflectable` implementation for types that are also `Decodable`.
    ///
    /// See `Reflectable`.
    public static func reflectProperties(depth: Int) throws -> [ReflectedProperty] {
        return try decodeProperties(depth: depth)
    }

    /// Default `Reflectable` implementation for types that are also `Decodable`.
    ///
    /// See `Reflectable`.
    public static func reflectProperty<T>(forKey keyPath: WritableKeyPath<Self, T>) throws -> ReflectedProperty?
        where T: ReflectionDecodable
    {
        return try decodeProperty(forKey: keyPath)
    }
}

extension Decodable where Self: Encodable {
    /// Decodes all `CodableProperty`s for this type. This requires that all propeties on this type are `ReflectionDecodable`.
    ///
    /// This is used to provide a default implementation for `reflectProperties(depth:)` on `Reflectable`.
    ///
    /// - parameters: depth: The level of nesting to use.
    ///                      If `0`, the top-most properties will be returned.
    ///                      If `1`, the first layer of nested properties, and so-on.
    /// - throws: Any error decoding this type's properties.
    /// - returns: All `ReflectedProperty`s at the specified depth.
    public static func decodeProperties(depth: Int) throws -> [ReflectedProperty] {
        // Using Void as the generic type in order to not return true when comparing types
        // T.Type is Value (If it is Any, will it allways return true and may cause a bug)
        let decoder = HiLoDecoder<Void, Void>(signal: .lo)
        _ = try Self(from: decoder)
        return decoder.properties.filter { $0.path.count == depth + 1 }
    }

    /// Decodes a `CodableProperty` for the supplied `KeyPath`. This requires that all propeties on this
    /// type are `ReflectionDecodable`.
    ///
    /// This is used to provide a default implementation for `reflectProperty(forKey:)` on `Reflectable`.
    ///
    /// - parameters:
    ///     - keyPath: `KeyPath` to decode a property for.
    /// - throws: Any error decoding this property.
    /// - returns: `ReflectedProperty` if one was found.
    public static func decodeProperty<T>(forKey keyPath: WritableKeyPath<Self, T>) throws -> ReflectedProperty?
        where T: ReflectionDecodable
    {
        if let cached = ReflectedPropertyCache.storage[keyPath] {
            return cached
        }
        
        var lo = try Self(from: HiLoDecoder<Self, T>(signal: .lo))
        lo[keyPath: keyPath] = T.reflectDecoded().1
        let e = HiLoEncoder<Self, T>()
        try lo.encode(to: e)
        guard let hi = e.hi else {
            return nil
        }
        return .init(T.self, at: hi.map { $0.stringValue })
    }
}

// MARK: Private

/// Caches derived `ReflectedProperty`s so that they only need to be decoded once per thread.
private final class ReflectedPropertyCache: NSObject {
    /// Thread-specific shared storage.
    static var storage: [AnyKeyPath: ReflectedProperty] {
        get {
            return Thread.current.reflectedPropertyCache.storage
        }
        set {
            Thread.current.reflectedPropertyCache.storage = newValue
        }
    }

    /// Instance storage.
    private var storage: [AnyKeyPath: ReflectedProperty]

    /// Creates a new `ReflectedPropertyCache`.
    override init() {
        self.storage = [:]
    }
}

private extension Thread {
    /// Access this thread's ReflectedPropertyCache
    var reflectedPropertyCache: ReflectedPropertyCache {
        get {
            if let existing = Thread.current.threadDictionary[_key] as? ReflectedPropertyCache {
                return existing
            } else {
                let new = ReflectedPropertyCache()
                Thread.current.threadDictionary[_key] = new
                return new
            }
        }
    }
}

/// Private key for storing ReflectedPropertyCache in a thread cache
private let _key = "codes.vapor.codable-kit.reflection-cache"
