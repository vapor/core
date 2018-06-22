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
        where T: Decodable
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
        let decoder = HiLoDecoder(signal: .lo)
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
        where T: Decodable
    {
        if let cached = ReflectedPropertyCache.storage[keyPath] {
            return cached
        }
        
        var lo = try Self(from: HiLoDecoder(signal: .lo))
        lo[keyPath: keyPath] = try T(from: HiLoDecoder(signal: .hi))
        let e = HiEncoder()
        try lo.encode(to: e)
        guard let hi = e.hi else {
            return nil
        }
        return .init(T.self, at: hi.map { $0.stringValue })
    }
}

/// Caches derived `ReflectedProperty`s so that they only need to be decoded once per thread.
final class ReflectedPropertyCache {
    /// Thread-specific shared storage.
    static var storage: [AnyKeyPath: ReflectedProperty] {
        get {
            let cache = ReflectedPropertyCache.thread.currentValue ?? .init()
            return cache.storage
        }
        set {
            let cache = ReflectedPropertyCache.thread.currentValue ?? .init()
            cache.storage = newValue
            ReflectedPropertyCache.thread.currentValue = cache
        }
    }

    /// Private `ThreadSpecificVariable` powering this cache.
    private static let thread: ThreadSpecificVariable<ReflectedPropertyCache> = .init()

    /// Instance storage.
    private var storage: [AnyKeyPath: ReflectedProperty]

    /// Creates a new `ReflectedPropertyCache`.
    init() {
        self.storage = [:]
    }
}
