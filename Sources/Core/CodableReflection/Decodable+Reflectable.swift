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
    /// See `Reflectable.reflectProperty(forKey:)`
    public static func reflectProperty<T>(forKey keyPath: KeyPath<Self, T>) throws -> ReflectedProperty? {
        return try decodeProperty(forKey: keyPath)
    }
}

extension Decodable {
    /// Decodes all `CodableProperty`s for this type. This requires that all propeties on this type are `ReflectionCodable`.
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
    /// type are `ReflectionCodable`.
    ///
    /// This is used to provide a default implementation for `reflectProperty(forKey:)` on `Reflectable`.
    ///
    /// - parameters:
    ///     - keyPath: KeyPath to decode a property for.
    /// - throws: Any error decoding this property.
    /// - returns: `ReflectedProperty` if one was found.
    public static func decodeProperty<T>(forKey keyPath: KeyPath<Self, T>) throws -> ReflectedProperty? {
        guard T.self is AnyReflectionCodable.Type else {
            throw CoreError(identifier: "reflectionCodable", reason: "`\(T.self)` does not conform to `ReflectionCodable`.")
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

                guard let t = T.self as? AnyReflectionCodable.Type else {
                    break b
                }

                if try t.anyReflectCodableIsLeft(decoded[keyPath: keyPath]) {
                    return .init(T.self, at: codingPath.map { $0.stringValue })
                }
            }
        }
    }
}
