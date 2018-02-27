final class ZeroDecoder: Decoder {
    var codingPath: [CodingKey]
    var userInfo: [CodingUserInfoKey : Any]

    init() {
        self.codingPath = []
        self.userInfo = [:]
    }

    func container<Key>(keyedBy type: Key.Type) throws -> KeyedDecodingContainer<Key> where Key : CodingKey {
        return KeyedDecodingContainer(ZeroKeyedDecoder<Key>())
    }

    func unkeyedContainer() throws -> UnkeyedDecodingContainer {
        return ZeroUnkeyedDecoder()
    }

    func singleValueContainer() throws -> SingleValueDecodingContainer {
        return ZeroSingleValueDecoder()
    }
}

final class ZeroUnkeyedDecoder: UnkeyedDecodingContainer {
    var codingPath: [CodingKey]
    var count: Int?
    var isAtEnd: Bool
    var currentIndex: Int
    init() {
        self.codingPath = []
        self.count = nil
        self.isAtEnd = true
        self.currentIndex = 0
    }
    func decodeNil() throws -> Bool { return false }
    func decode(_ type: Bool.Type) throws -> Bool {
        return false
    }
    func decode(_ type: String.Type) throws -> String {
        return "0"
    }
    func decode(_ type: Double.Type) throws -> Double {
        return 0
    }
    func decode(_ type: Float.Type) throws -> Float {
        return 0
    }
    func decode(_ type: Int.Type) throws -> Int {
        return 0
    }
    func decode(_ type: Int8.Type) throws -> Int8 {
        return 0
    }
    func decode(_ type: Int16.Type) throws -> Int16 {
        return 0
    }
    func decode(_ type: Int32.Type) throws -> Int32 {
        return 0
    }
    func decode(_ type: Int64.Type) throws -> Int64 {
        return 0
    }
    func decode(_ type: UInt.Type) throws -> UInt {
        return 0
    }
    func decode(_ type: UInt8.Type) throws -> UInt8 {
        return 0
    }
    func decode(_ type: UInt16.Type) throws -> UInt16 {
        return 0
    }
    func decode(_ type: UInt32.Type) throws -> UInt32 {
        return 0
    }
    func decode(_ type: UInt64.Type) throws -> UInt64 {
        return 0
    }
    func decode<T>(_ type: T.Type) throws -> T where T : Decodable {
        if let type = T.self as? AnyKeyStringDecodable.Type {
            return type._keyStringFalse as! T
        } else {
            return try T(from: ZeroDecoder())
        }
    }
    func nestedContainer<NestedKey>(keyedBy type: NestedKey.Type) throws -> KeyedDecodingContainer<NestedKey> where NestedKey : CodingKey {
        return KeyedDecodingContainer(ZeroKeyedDecoder<NestedKey>())
    }
    func nestedUnkeyedContainer() throws -> UnkeyedDecodingContainer {
        return ZeroUnkeyedDecoder()
    }
    func superDecoder() throws -> Decoder {
        return ZeroDecoder()
    }
}

final class ZeroKeyedDecoder<K>: KeyedDecodingContainerProtocol where K: CodingKey {
    typealias Key = K
    var codingPath: [CodingKey]
    var allKeys: [K]
    init() {
        self.codingPath = []
        self.allKeys = []
    }
    func contains(_ key: K) -> Bool {
        return false
    }
    func decodeNil(forKey key: K) throws -> Bool {
        return false
    }
    func decode(_ type: Bool.Type, forKey key: K) throws -> Bool {
        return false
    }
    func decode(_ type: String.Type, forKey key: K) throws -> String {
        return "0"
    }
    func decode(_ type: Double.Type, forKey key: K) throws -> Double {
        return 0
    }
    func decode(_ type: Float.Type, forKey key: K) throws -> Float {
        return 0
    }
    func decode(_ type: Int.Type, forKey key: K) throws -> Int {
        return 0
    }
    func decode(_ type: Int8.Type, forKey key: K) throws -> Int8 {
        return 0
    }
    func decode(_ type: Int16.Type, forKey key: K) throws -> Int16 {
        return 0
    }
    func decode(_ type: Int32.Type, forKey key: K) throws -> Int32 {
        return 0
    }
    func decode(_ type: Int64.Type, forKey key: K) throws -> Int64 {
        return 0
    }
    func decode(_ type: UInt.Type, forKey key: K) throws -> UInt {
        return 0
    }
    func decode(_ type: UInt8.Type, forKey key: K) throws -> UInt8 {
        return 0
    }
    func decode(_ type: UInt16.Type, forKey key: K) throws -> UInt16 {
        return 0
    }
    func decode(_ type: UInt32.Type, forKey key: K) throws -> UInt32 {
        return 0
    }
    func decode(_ type: UInt64.Type, forKey key: K) throws -> UInt64 {
        return 0
    }
    func decode<T>(_ type: T.Type, forKey key: K) throws -> T where T : Decodable {
        if let type = T.self as? AnyKeyStringDecodable.Type {
            return type._keyStringFalse as! T
        } else {
            return try T(from: ZeroDecoder())
        }
    }
    func nestedContainer<NestedKey>(keyedBy type: NestedKey.Type, forKey key: K) throws -> KeyedDecodingContainer<NestedKey> where NestedKey : CodingKey {
        return KeyedDecodingContainer(ZeroKeyedDecoder<NestedKey>())
    }
    func nestedUnkeyedContainer(forKey key: K) throws -> UnkeyedDecodingContainer {
        return ZeroUnkeyedDecoder()
    }
    func superDecoder() throws -> Decoder {
        return ZeroDecoder()
    }
    func superDecoder(forKey key: K) throws -> Decoder {
        return ZeroDecoder()
    }
}

final class ZeroSingleValueDecoder: SingleValueDecodingContainer {
    var codingPath: [CodingKey]

    init() {
        self.codingPath = []
    }

    func decodeNil() -> Bool {
        return false
    }

    func decode(_ type: Bool.Type) throws -> Bool {
        return false
    }
    func decode(_ type: String.Type) throws -> String {
        return "0"
    }
    func decode(_ type: Double.Type) throws -> Double {
        return 0
    }
    func decode(_ type: Float.Type) throws -> Float {
        return 0
    }
    func decode(_ type: Int.Type) throws -> Int {
        return 0
    }
    func decode(_ type: Int8.Type) throws -> Int8 {
        return 0
    }
    func decode(_ type: Int16.Type) throws -> Int16 {
        return 0
    }
    func decode(_ type: Int32.Type) throws -> Int32 {
        return 0
    }
    func decode(_ type: Int64.Type) throws -> Int64 {
        return 0
    }
    func decode(_ type: UInt.Type) throws -> UInt {
        return 0
    }
    func decode(_ type: UInt8.Type) throws -> UInt8 {
        return 0
    }
    func decode(_ type: UInt16.Type) throws -> UInt16 {
        return 0
    }
    func decode(_ type: UInt32.Type) throws -> UInt32 {
        return 0
    }
    func decode(_ type: UInt64.Type) throws -> UInt64 {
        return 0
    }
    func decode<T>(_ type: T.Type) throws -> T where T : Decodable {
        if let type = T.self as? AnyKeyStringDecodable.Type {
            return type._keyStringFalse as! T
        } else {
            return try T(from: ZeroDecoder())
        }
    }
}
