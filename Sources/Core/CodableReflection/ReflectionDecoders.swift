/// Internal types for powering the default implementation of `Reflectable` for `Decodable` types.
///
/// See `Decodable.decodeProperties(depth:)` and `Decodable.decodeProperty(forKey:)` for more information.

// MARK: Internal

/// Reference class for collecting information about `Decodable` types when initializing them.
final class ReflectionDecoderContext {
    /// If set, this is the `CodingKey` path to the truthy value in the initialized model.
    var activeCodingPath: [CodingKey]?

    /// Sets a maximum depth for decoding nested types like optionals and structs. This value ensures
    /// that models with recursive structures can be decoded without looping infinitely.
    var maxDepth: Int

    /// An array of all properties seen while initilaizing the `Decodable` type.
    var properties: [ReflectedProperty]

    /// If `true`, the property be decoded currently should be set to a truthy value.
    /// This property will cycle each time it is called.
    var isActive: Bool {
        defer { currentOffset += 1 }
        return currentOffset == activeOffset
    }

    /// This decoder context's curent active offset. This will determine which property gets
    /// set to a truthy value while decoding.
    private var activeOffset: Int

    /// Current offset. This is equal to the number of times `isActive` has been called so far.
    private var currentOffset: Int

    /// Creates a new `ReflectionDecoderContext`.
    init(activeOffset: Int, maxDepth: Int) {
        self.activeCodingPath = nil
        self.maxDepth = maxDepth
        self.properties = []
        self.activeOffset = activeOffset
        currentOffset = 0
    }

    /// Adds a property to this `ReflectionDecoderContext`.
    func addProperty<T>(type: T.Type, at path: [CodingKey]) {
        let path = path.map { $0.stringValue }
        // remove any duplicates, favoring the new type
        properties = properties.filter { $0.path != path }
        let property = ReflectedProperty.init(T.self, at: path)
        properties.append(property)
    }
}

/// Main decoder for codable reflection.
struct ReflectionDecoder: Decoder {
    var codingPath: [CodingKey]
    var context: ReflectionDecoderContext
    var userInfo: [CodingUserInfoKey: Any] { return [:] }

    init(codingPath: [CodingKey], context: ReflectionDecoderContext) {
        self.codingPath = codingPath
        self.context = context
    }

    func container<Key>(keyedBy type: Key.Type) throws -> KeyedDecodingContainer<Key> where Key : CodingKey {
        return .init(ReflectionKeyedDecoder<Key>(codingPath: codingPath, context: context))
    }

    func unkeyedContainer() throws -> UnkeyedDecodingContainer {
        return ReflectionUnkeyedDecoder(codingPath: codingPath, context: context)
    }

    func singleValueContainer() throws -> SingleValueDecodingContainer {
        return ReflectionSingleValueDecoder(codingPath: codingPath, context: context)
    }
}

/// Single value decoder for codable reflection.
struct ReflectionSingleValueDecoder: SingleValueDecodingContainer {
    var codingPath: [CodingKey]
    var context: ReflectionDecoderContext

    init(codingPath: [CodingKey], context: ReflectionDecoderContext) {
        self.codingPath = codingPath
        self.context = context
    }

    func decodeNil() -> Bool {
        return false
    }

    func decode<T>(_ type: T.Type) throws -> T where T: Decodable {
        context.addProperty(type: T.self, at: codingPath)
        let type = try forceCast(T.self)
        let reflected = try type.anyReflectDecoded()
        if context.isActive {
            context.activeCodingPath = codingPath
            return reflected.0 as! T
        }
        return reflected.1 as! T
    }
}

/// Keyed decoder for codable reflection.
final class ReflectionKeyedDecoder<K>: KeyedDecodingContainerProtocol where K: CodingKey {
    typealias Key = K
    var allKeys: [K] { return [] }
    var codingPath: [CodingKey]
    var context: ReflectionDecoderContext
    var nextIsOptional: Bool

    init(codingPath: [CodingKey], context: ReflectionDecoderContext) {
        self.codingPath = codingPath
        self.context = context
        self.nextIsOptional = false
    }

    func contains(_ key: K) -> Bool {
        nextIsOptional = true
        return true
    }

    func decodeNil(forKey key: K) throws -> Bool {
        if context.maxDepth > codingPath.count {
            return false
        }
        return true
    }

    func nestedContainer<NestedKey>(keyedBy type: NestedKey.Type, forKey key: K) throws -> KeyedDecodingContainer<NestedKey> where NestedKey: CodingKey {
        return .init(ReflectionKeyedDecoder<NestedKey>(codingPath: codingPath + [key], context: context))
    }

    func nestedUnkeyedContainer(forKey key: K) throws -> UnkeyedDecodingContainer {
        return ReflectionUnkeyedDecoder(codingPath: codingPath + [key], context: context)
    }

    func superDecoder() throws -> Decoder {
        return ReflectionDecoder(codingPath: codingPath, context: context)
    }

    func superDecoder(forKey key: K) throws -> Decoder {
        return ReflectionDecoder(codingPath: codingPath + [key], context: context)
    }

    func decode<T>(_ type: T.Type, forKey key: K) throws -> T where T : Decodable {
        if nextIsOptional {
            context.addProperty(type: T?.self, at: codingPath + [key])
            nextIsOptional = false
        } else {
            context.addProperty(type: T.self, at: codingPath + [key])
        }
        if let type = T.self as? AnyReflectionDecodable.Type, let reflected = try? type.anyReflectDecoded() {
            if context.isActive {
                context.activeCodingPath = codingPath + [key]
                return reflected.0 as! T
            }
            return reflected.1 as! T
        } else {
            let decoder = ReflectionDecoder(codingPath: codingPath + [key], context: context)
            return try T(from: decoder)
        }
    }
}

/// Unkeyed decoder for codable reflection.
fileprivate struct ReflectionUnkeyedDecoder: UnkeyedDecodingContainer {
    var count: Int?
    var isAtEnd: Bool
    var currentIndex: Int
    var codingPath: [CodingKey]
    var context: ReflectionDecoderContext

    init(codingPath: [CodingKey], context: ReflectionDecoderContext) {
        self.codingPath = codingPath
        self.context = context
        self.currentIndex = 0
        if context.isActive {
            self.count = 1
            self.isAtEnd = false
            context.activeCodingPath = codingPath
        } else {
            self.count = 0
            self.isAtEnd = true
        }
    }

    mutating func decodeNil() throws -> Bool {
        isAtEnd = true
        return true
    }

    mutating func decode<T>(_ type: T.Type) throws -> T where T : Decodable {
        context.addProperty(type: [T].self, at: codingPath)
        isAtEnd = true
        if let type = T.self as? AnyReflectionDecodable.Type, let reflected = try? type.anyReflectDecoded() {
            return reflected.0 as! T
        } else {
            let decoder = ReflectionDecoder(codingPath: codingPath, context: context)
            return try T(from: decoder)
        }
    }

    mutating func nestedContainer<NestedKey>(keyedBy type: NestedKey.Type) throws -> KeyedDecodingContainer<NestedKey> where NestedKey : CodingKey {
        return .init(ReflectionKeyedDecoder<NestedKey>(codingPath: codingPath, context: context))
    }

    mutating func nestedUnkeyedContainer() throws -> UnkeyedDecodingContainer {
        return ReflectionUnkeyedDecoder(codingPath: codingPath, context: context)
    }

    mutating func superDecoder() throws -> Decoder {
        return ReflectionDecoder(codingPath: codingPath, context: context)
    }
}
