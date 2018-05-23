/// Default `Reflectable` implementation for types that are also `Decodable`.
extension Reflectable where Self: Decodable {
    /// Default `Reflectable` implementation for types that are also `Decodable`.
    ///
    /// See `Reflectable.reflectProperties(depth:)`
    public static func reflectProperties(depth: Int) throws -> [ReflectedProperty] {
        return try decodeProperties(depth: depth)
    }

    /// Default `Reflectable` implementation for types that are also `Decodable`.
    ///
    /// See `AnyReflectable`.
    public static func anyReflectProperty(valueType: Any.Type, keyPath: AnyKeyPath) throws -> ReflectedProperty? {
        return try anyDecodeProperty(valueType: valueType, keyPath: keyPath)
    }
}

extension Decodable {
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
        let context = ReflectionDecoderContext(activeOffset: 0, maxDepth: 42)
        let decoder = ReflectionDecoder(codingPath: [], context: context)
        _ = try Self(from: decoder)
        return context.properties.filter { $0.path.count == depth + 1 }
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
    public static func decodeProperty<T>(forKey keyPath: KeyPath<Self, T>) throws -> ReflectedProperty? {
        return try anyDecodeProperty(valueType: T.self, keyPath: keyPath)
    }

    /// Decodes a `CodableProperty` for the supplied `KeyPath`. This requires that all propeties on this
    /// type are `ReflectionDecodable`.
    ///
    /// This is used to provide a default implementation for `reflectProperty(forKey:)` on `Reflectable`.
    ///
    /// - parameters:
    ///     - keyPath: `AnyKeyPath` to decode a property for.
    /// - throws: Any error decoding this property.
    public static func anyDecodeProperty(valueType: Any.Type, keyPath: AnyKeyPath) throws -> ReflectedProperty? {
        guard valueType is AnyReflectionDecodable.Type else {
            throw CoreError(identifier: "ReflectionDecodable", reason: "`\(valueType)` does not conform to `ReflectionDecodable`.")
        }

        if let cached = ReflectedPropertyCache.storage[keyPath] {
            return cached
        }

        var maxDepth = 0
        a: while true {
            defer { maxDepth += 1 }
            var activeOffset = 0

            if maxDepth > 42 {
                return nil
            }

            b: while true {
                defer { activeOffset += 1 }
                let context = ReflectionDecoderContext(activeOffset: activeOffset, maxDepth: maxDepth)
                let decoder = ReflectionDecoder(codingPath: [], context: context)

                let decoded = try Self(from: decoder)
                guard let codingPath = context.activeCodingPath else {
                    // no more values are being set at this depth
                    break b
                }

                guard let t = valueType as? AnyReflectionDecodable.Type, let left = decoded[keyPath: keyPath] else {
                    break b
                }

                if try t.anyReflectDecodedIsLeft(left) {
                    let property = ReflectedProperty(any: valueType, at: codingPath.map { $0.stringValue })
                    ReflectedPropertyCache.storage[keyPath] = property
                    return property
                }
            }
        }
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
