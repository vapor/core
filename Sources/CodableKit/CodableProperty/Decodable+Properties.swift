/// Add free `CodingKeyPropertiesStaticRepresentable` conformance to `Decodable` types.
extension CodableProperties where Self: Decodable {
    /// See `CodingKeyPropertiesStaticRepresentable.properties(depth:)`
    public static func properties(depth: Int) throws -> [CodableProperty] {
        return try decodeProperties(depth: depth)
    }
}

extension Decodable {
    /// Collect's the Decodable type's properties into an
    /// array of `CodingKeyProperty` using the `init(from: Decoder)` method.
    /// - parameter depth: Controls how deeply nested optional decoding will go.
    public static func decodeProperties(depth: Int) throws -> [CodableProperty] {
        let result = CodingKeyCollectorResult(depth: depth)
        let decoder = CodingKeyCollector(codingPath: [], result: result)
        do {
            _ = try Self(from: decoder)
        } catch {
            throw CodableKitError(
                identifier: "properties",
                reason: "Decoding properties from \(Self.self) failed: \(error).",
                suggestedFixes: [
                    "Ensure all types on the model you are decoding conform to `KeyStringDecodable`."
                ],
                possibleCauses: [
                    "One of the properties on \(Self.self) is not `KeyStringDecodable`."
                ],
                source: .capture()
            )
        }
        return result.properties
    }
}

/// MARK: Private - Decoders

fileprivate final class CodingKeyCollectorResult {
    var properties: [CodableProperty]
    var depth: Int
    var nextIsOptional: Bool

    init(depth: Int) {
        self.depth = depth
        properties = []
        self.nextIsOptional = false
    }

    func add<T>(type: T.Type, atPath codingPath: [CodingKey]) {
        let property: CodableProperty
        if nextIsOptional {
            nextIsOptional = false
            property = CodableProperty(T?.self, at: codingPath.map { $0.stringValue })
        } else {
            property = CodableProperty(T.self, at: codingPath.map { $0.stringValue })
        }
        properties.append(property)
    }
}

fileprivate final class CodingKeyCollector: Decoder {
    var codingPath: [CodingKey]
    var result: CodingKeyCollectorResult
    var userInfo: [CodingUserInfoKey: Any]

    init(codingPath: [CodingKey], result: CodingKeyCollectorResult) {
        self.codingPath = codingPath
        self.result = result
        userInfo = [:]
    }

    func container<Key>(keyedBy type: Key.Type) throws -> KeyedDecodingContainer<Key> where Key : CodingKey {
        let container = CodingKeyCollectorKeyedDecoder<Key>(
            codingPath: codingPath,
            result: result
        )
        return KeyedDecodingContainer(container)
    }

    func unkeyedContainer() throws -> UnkeyedDecodingContainer {
        return CodingKeyCollectorUnkeyedDecoder(codingPath: codingPath, result: result)
    }

    func singleValueContainer() throws -> SingleValueDecodingContainer {
        return CodingKeyCollectorSingleValueDecoder(codingPath: codingPath, result: result)
    }
}

fileprivate struct CodingKeyCollectorSingleValueDecoder: SingleValueDecodingContainer {
    var codingPath: [CodingKey]
    var result: CodingKeyCollectorResult

    init(codingPath: [CodingKey], result: CodingKeyCollectorResult) {
        self.codingPath = codingPath
        self.result = result
    }

    func decodeNil() -> Bool {
        return false
    }

    func decode<T>(_ type: T.Type) throws -> T where T: Decodable {
        if let keyString = T.self as? AnyKeyStringDecodable.Type {
            result.add(type: type, atPath: codingPath)
            return keyString._keyStringFalse as! T
        } else {
            if codingPath.count >= result.depth {
                // stop nesting
                result.add(type: type, atPath: codingPath)
                return try T(from: ZeroDecoder())
            } else {
                // we can continue nesting
                let decoder = CodingKeyCollector(codingPath: codingPath, result: result)
                return try T(from: decoder)
            }
        }
    }
}

fileprivate struct CodingKeyCollectorKeyedDecoder<K>: KeyedDecodingContainerProtocol where K: CodingKey {
    typealias Key = K
    var allKeys: [K]
    var codingPath: [CodingKey]
    var result: CodingKeyCollectorResult

    init(codingPath: [CodingKey], result: CodingKeyCollectorResult) {
        self.codingPath = codingPath
        self.result = result
        self.allKeys = []
    }

    func contains(_ key: K) -> Bool {
        result.nextIsOptional = true
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
        let container = CodingKeyCollectorKeyedDecoder<NestedKey>(
            codingPath: codingPath + [key],
            result: result
        )
        return KeyedDecodingContainer(container)
    }

    func nestedUnkeyedContainer(forKey key: K) throws -> UnkeyedDecodingContainer {
        return CodingKeyCollectorUnkeyedDecoder(codingPath: codingPath + [key], result: result)
    }

    func superDecoder() throws -> Decoder {
        return CodingKeyCollector(codingPath: codingPath, result: result)
    }

    func superDecoder(forKey key: K) throws -> Decoder {
        return CodingKeyCollector(codingPath: codingPath + [key], result: result)
    }

    func decode<T>(_ type: T.Type, forKey key: K) throws -> T where T: Decodable {
        if let keyString = T.self as? AnyKeyStringDecodable.Type {
            result.add(type: T.self, atPath: codingPath + [key])
            return keyString._keyStringFalse as! T
        } else {
            let path = codingPath + [key]
            if path.count >= result.depth {
                // stop nesting
                result.add(type: type, atPath: codingPath + [key])
                return try T(from: ZeroDecoder())
            } else {
                // we can continue nesting
                let decoder = CodingKeyCollector(codingPath: path, result: result)
                return try T(from: decoder)
            }
        }
    }
}

fileprivate struct CodingKeyCollectorUnkeyedDecoder: UnkeyedDecodingContainer {
    var codingPath: [CodingKey]
    var count: Int?
    var isAtEnd: Bool
    var currentIndex: Int
    var result: CodingKeyCollectorResult

    init(codingPath: [CodingKey], result: CodingKeyCollectorResult) {
        self.codingPath = codingPath
        self.result = result
        self.count = nil
        self.isAtEnd = true
        self.currentIndex = 0
    }

    func decodeNil() -> Bool {
        return false
    }

    func decode<T>(_ type: T.Type) throws -> T where T: Decodable {
        if let keyString = T.self as? AnyKeyStringDecodable.Type {
            result.add(type: [T].self, atPath: codingPath)
            return keyString._keyStringFalse as! T
        } else {
            if codingPath.count + 1 >= result.depth {
                // stop nesting
                result.add(type: [T].self, atPath: codingPath)
                return try T(from: ZeroDecoder())
            } else {
                // we can continue nesting
                let decoder = CodingKeyCollector(codingPath: codingPath, result: result)
                return try T(from: decoder)
            }
        }
    }

    mutating func nestedContainer<NestedKey>(keyedBy type: NestedKey.Type) throws -> KeyedDecodingContainer<NestedKey> where NestedKey : CodingKey {
        let container = CodingKeyCollectorKeyedDecoder<NestedKey>(codingPath: codingPath, result: result)
        return .init(container)
    }

    mutating func nestedUnkeyedContainer() throws -> UnkeyedDecodingContainer {
        return CodingKeyCollectorUnkeyedDecoder(codingPath: codingPath, result: result)
    }

    mutating func superDecoder() throws -> Decoder {
        return CodingKeyCollector(codingPath: codingPath, result: result)
    }
}
