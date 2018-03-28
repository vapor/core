extension Reflectable where Self: Decodable {
    public static func reflectProperty<T>(forKey keyPath: KeyPath<Self, T>) throws -> ReflectedProperty? {
        return try decodeProperty(forKey: keyPath)
    }


    public static func reflectProperties() throws -> [ReflectedProperty] {
        return try decodeProperties()
    }
}

extension Decodable {
    /// Automatically decodes a `CodableProperty` for the supplied `KeyPath`.
    public static func decodeProperty<T>(forKey keyPath: KeyPath<Self, T>) throws -> ReflectedProperty? {
        guard T.self is AnyReflectionCodable.Type else {
            throw CoreError(identifier: "reflectionCodable", reason: "`\(T.self)` does not conform to `ReflectionCodable`.")
        }

        var depth = 0
        a: while true {
            defer { depth += 1 }
            var progress = 0

            if depth > 42 {
                return nil
            }

            b: while true {
                defer { progress += 1 }
                let context = ReflectionDecoderContext(progress: progress, depth: depth)
                let decoder = ReflectionDecoder(codingPath: [], context: context)

                let decoded = try Self(from: decoder)
                guard let codingPath = context.codingPath else {
                    // no more values are being set at this depth
                    break b
                }

                guard let t = T.self as? AnyReflectionCodable.Type else {
                    break b
                }

                if try t.anyReflectIsTrue(decoded[keyPath: keyPath]) {
                    return .init(T.self, at: codingPath.map { $0.stringValue })
                }
            }
        }
    }

    public static func decodeProperties(depth: Int = 1) throws -> [ReflectedProperty] {
        let context = ReflectionDecoderContext(progress: 0, depth: depth)
        let decoder = ReflectionDecoder(codingPath: [], context: context)
        _ = try Self(from: decoder)
        return context.properties
    }
}
