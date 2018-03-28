struct ReflectionDecoder: Decoder {
    var codingPath: [CodingKey]
    var context: ReflectionDecoderContext
    var userInfo: [CodingUserInfoKey: Any] { return [:] }

    init(codingPath: [CodingKey], context: ReflectionDecoderContext) {
        print("\(Swift.type(of: self)).\(#function)")
        self.codingPath = codingPath
        self.context = context
    }

    func container<Key>(keyedBy type: Key.Type) throws -> KeyedDecodingContainer<Key> where Key : CodingKey {
        print("\(Swift.type(of: self)).\(#function)")
        return .init(ReflectionKeyedDecoder<Key>(codingPath: codingPath, context: context))
    }

    func unkeyedContainer() throws -> UnkeyedDecodingContainer {
        print("\(Swift.type(of: self)).\(#function)")
        return ReflectionUnkeyedDecoder(codingPath: codingPath, context: context)
    }

    func singleValueContainer() throws -> SingleValueDecodingContainer {
        print("\(Swift.type(of: self)).\(#function)")
        return ReflectionSingleValueDecoder(codingPath: codingPath, context: context)
    }
}

struct ReflectionSingleValueDecoder: SingleValueDecodingContainer {
    var codingPath: [CodingKey]
    var context: ReflectionDecoderContext

    init(codingPath: [CodingKey], context: ReflectionDecoderContext) {
        print("\(Swift.type(of: self)).\(#function)")
        self.codingPath = codingPath
        self.context = context
    }

    func decodeNil() -> Bool {
        print("\(Swift.type(of: self)).\(#function)")
        return false
    }

    func decode<T>(_ type: T.Type) throws -> T where T: Decodable {
        print("\(Swift.type(of: self)).\(#function)")
        context.addProperty(type: T.self, at: codingPath)
        if let type = T.self as? AnyReflectionCodable.Type {
            if context.cycle {
                context.codingPath = codingPath
                return try type.anyReflectTrue() as! T
            }
            return try type.anyReflectFalse() as! T
        } else {
            throw CoreError(
                identifier: "reflectionCodable",
                reason: "\(T.self) is not `ReflectionCodable`",
                suggestedFixes: [
                    "Conform `\(T.self)` to `ReflectionCodable`: `extension \(T.self): ReflectionCodable { }`."
                ]
            )
        }
    }
}

struct ReflectionKeyedDecoder<K>: KeyedDecodingContainerProtocol where K: CodingKey {
    typealias Key = K
    var allKeys: [K] { return [] }
    var codingPath: [CodingKey]
    var context: ReflectionDecoderContext

    init(codingPath: [CodingKey], context: ReflectionDecoderContext) {
        self.codingPath = codingPath
        self.context = context
        print("\(Swift.type(of: self)).\(#function)")
    }

    func contains(_ key: K) -> Bool {
        print("\(Swift.type(of: self)).\(#function)")
        context.nextIsOptional = true
        return true
    }

    func decodeNil(forKey key: K) throws -> Bool {
        print("\(Swift.type(of: self)).\(#function)")
        if context.depth > codingPath.count {
            return false
        }
        return true
    }

    func nestedContainer<NestedKey>(keyedBy type: NestedKey.Type, forKey key: K) throws -> KeyedDecodingContainer<NestedKey> where NestedKey: CodingKey {
        print("\(Swift.type(of: self)).\(#function) \(key.stringValue)")
        let container = ReflectionKeyedDecoder<NestedKey>(codingPath: codingPath + [key], context: context)
        return KeyedDecodingContainer(container)
    }

    func nestedUnkeyedContainer(forKey key: K) throws -> UnkeyedDecodingContainer {
        print("\(Swift.type(of: self)).\(#function) \(key.stringValue)")
        return ReflectionUnkeyedDecoder(codingPath: codingPath + [key], context: context)
    }

    func superDecoder() throws -> Decoder {
        print("\(Swift.type(of: self)).\(#function)")
        return ReflectionDecoder(codingPath: codingPath, context: context)
    }

    func superDecoder(forKey key: K) throws -> Decoder {
        print("\(Swift.type(of: self)).\(#function) \(key.stringValue)")
        return ReflectionDecoder(codingPath: codingPath + [key], context: context)
    }

    func decode<T>(_ type: T.Type, forKey key: K) throws -> T where T : Decodable {
        print("\(Swift.type(of: self)).\(#function) \(key.stringValue)")
        context.addProperty(type: T.self, at: codingPath + [key])
        if let type = T.self as? AnyReflectionCodable.Type {
            if context.cycle {
                context.codingPath = codingPath + [key]
                return try type.anyReflectTrue() as! T
            }
            return try type.anyReflectFalse() as! T
        } else {
            print("\(T.self) at \(key.stringValue) is not AnyReflectionCodable, invoking decoder...")
            let decoder = ReflectionDecoder(codingPath: codingPath + [key], context: context)
            return try T(from: decoder)
        }
    }
}

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
        if context.cycle {
            self.count = 1
            self.isAtEnd = false
            context.codingPath = codingPath
        } else {
            self.count = 0
            self.isAtEnd = true
        }
        print("\(type(of: self)).\(#function)")
    }

    mutating func decodeNil() throws -> Bool {
        print("\(type(of: self)).\(#function)")
        isAtEnd = true
        return true
    }

    mutating func decode<T>(_ type: T.Type) throws -> T where T : Decodable {
        print("\(Swift.type(of: self)).\(#function)")
        context.addProperty(type: [T].self, at: codingPath)
        isAtEnd = true
        if let type = T.self as? AnyReflectionCodable.Type {
            return try type.anyReflectTrue() as! T
        } else {
            let decoder = ReflectionDecoder(codingPath: codingPath, context: context)
            return try T(from: decoder)
        }
    }

    mutating func nestedContainer<NestedKey>(keyedBy type: NestedKey.Type) throws -> KeyedDecodingContainer<NestedKey> where NestedKey : CodingKey {
        print("\(Swift.type(of: self)).\(#function)")
        return .init(ReflectionKeyedDecoder<NestedKey>(codingPath: codingPath, context: context))
    }

    mutating func nestedUnkeyedContainer() throws -> UnkeyedDecodingContainer {
        print("\(type(of: self)).\(#function)")
        return ReflectionUnkeyedDecoder(codingPath: codingPath, context: context)
    }

    mutating func superDecoder() throws -> Decoder {
        print("\(type(of: self)).\(#function)")
        return ReflectionDecoder(codingPath: codingPath, context: context)
    }
}
