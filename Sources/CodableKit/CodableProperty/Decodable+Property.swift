import Core

/// Maps KeyPath to [CodingKey] on Decodable types.
extension Reflectable where Self: Decodable {
    /// See `CodableProperties.property(forKey:)`
    public static func reflectProperty<T>(forKey keyPath: KeyPath<Self, T>) throws -> ReflectedProperty {
        return try decodeProperty(forKey: keyPath)
    }
}

extension Decodable {
    /// Automatically decodes a `CodableProperty` for the supplied `KeyPath`.
    public static func decodeProperty<T>(forKey keyPath: KeyPath<Self, T>) throws -> ReflectedProperty {
        var depth = 0
        a: while true {
            defer { depth += 1 }
            var progress = 0

            if depth > 42 {
                throw CodableKitError(
                    identifier: "codingPathDepth",
                    reason: "Exceeded maximum `codingPath(forKey:)` depth.",
                    suggestedFixes: [],
                    possibleCauses: [
                        "The key path is a computed property, not a stored one: \(keyPath).",
                        "The key path you are attempting to decode is not parsed in `\(Self.self).init(from: Decoder)`"
                    ],
                    source: .capture()
                )
            }

            b: while true {
                defer { progress += 1 }
                let result = KeyStringDecoderResult(progress: progress, depth: depth)
                let decoder = KeyStringDecoder(codingPath: [], result: result)

                let decoded: Self
                do {
                    decoded = try Self(from: decoder)
                } catch {
                    throw CodableKitError(
                        identifier: "decodeError",
                        reason: "An error occured while decoding path: \(error).",
                        suggestedFixes: [
                            "Ensure all types on the model you are decoding conform to `KeyStringDecodable`."
                        ],
                        possibleCauses: [
                            "One of the properties on \(Self.self) is not `KeyStringDecodable`."
                        ],
                        source: .capture()
                    )
                }
                guard let codingPath = result.codingPath else {
                    // no more values are being set at this depth
                    break b
                }

                guard let t = T.self as? AnyKeyStringDecodable.Type else {
                    break b
                }

                if t._keyStringIsTrue(decoded[keyPath: keyPath]) {
                    return .init(T.self, at: codingPath.map { $0.stringValue })
                }
            }
        }
    }
}

// MARK: Private

fileprivate final class KeyStringDecoderResult {
    var codingPath: [CodingKey]?
    var progress: Int
    var current: Int
    var depth: Int
    var cycle: Bool {
        defer { current += 1 }
        return current == progress
    }

    init(progress: Int, depth: Int) {
        codingPath = nil
        current = 0
        self.depth = depth
        self.progress = progress
    }
}

// MARK: Coders

fileprivate final class KeyStringDecoder: Decoder {
    var codingPath: [CodingKey]
    var result: KeyStringDecoderResult
    var userInfo: [CodingUserInfoKey: Any]

    init(codingPath: [CodingKey], result: KeyStringDecoderResult) {
        self.codingPath = codingPath
        self.result = result
        userInfo = [:]
    }

    func container<Key>(keyedBy type: Key.Type) throws -> KeyedDecodingContainer<Key> where Key : CodingKey {
        let container = KeyStringKeyedDecoder<Key>(codingPath: codingPath, result: result)
        return KeyedDecodingContainer(container)
    }

    func unkeyedContainer() throws -> UnkeyedDecodingContainer {
        return KeyStringUnkeyedDecoder(codingPath: codingPath, result: result)
    }

    func singleValueContainer() throws -> SingleValueDecodingContainer {
        return KeyStringSingleValueDecoder(codingPath: codingPath, result: result)
    }
}

fileprivate struct KeyStringSingleValueDecoder: SingleValueDecodingContainer {
    var codingPath: [CodingKey]
    var result: KeyStringDecoderResult

    init(codingPath: [CodingKey], result: KeyStringDecoderResult) {
        self.codingPath = codingPath
        self.result = result
    }

    func decodeNil() -> Bool {
        return false
    }

    func decode<T>(_ type: T.Type) throws -> T where T: Decodable {
        if let type = T.self as? AnyKeyStringDecodable.Type {
            if result.cycle {
                result.codingPath = codingPath
                return type._keyStringTrue as! T
            }
            return type._keyStringFalse as! T
        } else {
            let decoder = KeyStringDecoder(codingPath: codingPath, result: result)
            return try T(from: decoder)
        }
    }
}

fileprivate struct KeyStringKeyedDecoder<K>: KeyedDecodingContainerProtocol where K: CodingKey {
    typealias Key = K
    var allKeys: [K]
    var codingPath: [CodingKey]
    var result: KeyStringDecoderResult

    init(codingPath: [CodingKey], result: KeyStringDecoderResult) {
        self.codingPath = codingPath
        self.result = result
        self.allKeys = []
    }

    func contains(_ key: K) -> Bool {
        return true
    }

    func decodeNil(forKey key: K) throws -> Bool {
        if result.depth > codingPath.count {
            return false
        }
        return true
    }

    func nestedContainer<NestedKey>(keyedBy type: NestedKey.Type, forKey key: K) throws -> KeyedDecodingContainer<NestedKey>
        where NestedKey: CodingKey
    {
        let container = KeyStringKeyedDecoder<NestedKey>(codingPath: codingPath + [key], result: result)
        return KeyedDecodingContainer(container)
    }

    func nestedUnkeyedContainer(forKey key: K) throws -> UnkeyedDecodingContainer {
        return KeyStringUnkeyedDecoder(codingPath: codingPath + [key], result: result)
    }

    func superDecoder() throws -> Decoder {
        return KeyStringDecoder(codingPath: codingPath, result: result)
    }

    func superDecoder(forKey key: K) throws -> Decoder {
        return KeyStringDecoder(codingPath: codingPath + [key], result: result)
    }

    func decode<T>(_ type: T.Type, forKey key: K) throws -> T where T : Decodable {
        if let type = T.self as? AnyKeyStringDecodable.Type {
            if result.cycle {
                result.codingPath = codingPath + [key]
                return type._keyStringTrue as! T
            }
            return type._keyStringFalse as! T
        } else {
            let decoder = KeyStringDecoder(codingPath: codingPath + [key], result: result)
            return try T(from: decoder)
        }
    }
}

fileprivate struct KeyStringUnkeyedDecoder: UnkeyedDecodingContainer {
    var count: Int?
    var isAtEnd: Bool
    var currentIndex: Int
    var codingPath: [CodingKey]
    var result: KeyStringDecoderResult

    init(codingPath: [CodingKey], result: KeyStringDecoderResult) {
        self.codingPath = codingPath
        self.result = result
        self.currentIndex = 0
        if result.cycle {
            self.count = 1
            self.isAtEnd = false
            result.codingPath = codingPath
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
        isAtEnd = true
        if let type = T.self as? AnyKeyStringDecodable.Type {
            return type._keyStringTrue as! T
        } else {
            let decoder = KeyStringDecoder(codingPath: codingPath, result: result)
            return try T(from: decoder)
        }
    }

    mutating func nestedContainer<NestedKey>(keyedBy type: NestedKey.Type) throws -> KeyedDecodingContainer<NestedKey> where NestedKey : CodingKey {
        let container = KeyStringKeyedDecoder<NestedKey>(codingPath: codingPath, result: result)
        return .init(container)
    }

    mutating func nestedUnkeyedContainer() throws -> UnkeyedDecodingContainer {
        return KeyStringUnkeyedDecoder(codingPath: codingPath, result: result)
    }

    mutating func superDecoder() throws -> Decoder {
        return KeyStringDecoder(codingPath: codingPath, result: result)
    }
}

