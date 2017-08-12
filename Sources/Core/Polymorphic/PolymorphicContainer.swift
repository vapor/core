import Foundation

internal final class PolymorphicContainer<
    Data: Polymorphic, K: CodingKey
>: UnkeyedDecodingContainer, SingleValueDecodingContainer, KeyedDecodingContainerProtocol {
    typealias Key = K
    enum Mode { case single, keyed, unkeyed }

    var decoder: PolymorphicDecoder<Data>
    var currentIndex: Int
    var mode: Mode
    var data: Data

    init(decoder: PolymorphicDecoder<Data>, mode: Mode, data: Data) {
        self.decoder = decoder
        self.mode = mode
        self.currentIndex = 0
        self.data = data
    }

    // MARK: Get

    func assertGet<K: CodingKey>(key: K) throws -> Data {
        guard let container = get(key: key) else {
            let path = codingPath.map { $0.stringValue } + [key.stringValue]
            throw PolymorphicError.missingKey(data, path: path)
        }

        return container
    }

    func get<K: CodingKey>(key: K) -> Data? {
        guard let key = decoder.codingKeyMap(key) else {
            return nil
        }
        return data.dictionary?[key.stringValue]
    }

    // MARK: Computed

    var allKeys: [K] {
        return data.dictionary?.keys.flatMap {
            Key(stringValue: $0)
        } ?? []
    }

    var codingPath: [CodingKey] {
        return decoder.codingPath
    }

    var count: Int? {
        return data.array?.count
    }

    var isAtEnd: Bool {
        guard let count = count else {
            return true
        }

        return currentIndex >= count
    }

    func contains(_ key: K) -> Bool {
        return allKeys.contains(where: { $0.stringValue == key.stringValue })
    }

    // MARK: Nested Unkeyed

    func nestedContainer<NestedKey>(
        keyedBy type: NestedKey.Type
    ) throws -> KeyedDecodingContainer<NestedKey> where NestedKey : CodingKey {
        let key = StringKey(currentIndex.description)
        return try decoder.with(pushedKey: key) {
            let data = try self.data.assertArray()[currentIndex]
            currentIndex += 1
            let cont = PolymorphicContainer<Data, NestedKey>(decoder: decoder, mode: .keyed, data: data)
            return KeyedDecodingContainer(cont)
        }
    }

    func nestedUnkeyedContainer() throws -> UnkeyedDecodingContainer {
        let key = StringKey(currentIndex.description)
        return try decoder.with(pushedKey: key) {
            let data = try self.data.assertArray()[currentIndex]
            currentIndex += 1
            return PolymorphicContainer<Data, Key>(decoder: decoder, mode: .unkeyed, data: data)
        }
    }

    // MARK: Nested Keyed

    func nestedContainer<NestedKey>(
        keyedBy type: NestedKey.Type,
        forKey key: K
    ) throws -> KeyedDecodingContainer<NestedKey> where NestedKey : CodingKey {
        return try decoder.with(pushedKey: key) {
            let data = try assertGet(key: key)
            let cont = PolymorphicContainer<Data, NestedKey>(decoder: decoder, mode: .keyed, data: data)
            return KeyedDecodingContainer(cont)
        }
    }

    func nestedUnkeyedContainer(forKey key: K) throws -> UnkeyedDecodingContainer {
        return try decoder.with(pushedKey: key) {
            let data = try assertGet(key: key)
            return PolymorphicContainer(decoder: decoder, mode: .unkeyed, data: data)
        }
    }

    // MARK: Super

    func superDecoder(forKey key: K) throws -> Decoder {
        return try decoder.with(pushedKey: key) {
            let data = try assertGet(key: key)
            return decoder.factory(Any.self, data, decoder)
        }
    }

    func superDecoder() throws -> Decoder {
        let key = StringKey(currentIndex.description)
        return try decoder.with(pushedKey: key) {
            let data = try self.data.assertArray()[currentIndex]
            currentIndex += 1
            return decoder.factory(Any.self, data, decoder)
        }
    }

    // MARK: Generic Type

    func decode<T>(_ type: T.Type) throws -> T where T : Decodable {
        let typed = decoder.factory(T.self, data, decoder)
        return try T(from: typed)
    }

    func decode<T>(_ type: T.Type, forKey key: K) throws -> T where T : Decodable {
        return try decoder.with(pushedKey: key) {
            let data = try assertGet(key: key)
            let typed = decoder.factory(T.self, data, decoder)
            return try T(from: typed)
        }
    }

    // MARK: Decode Unkeyed / Single

    public func decodeNil() -> Bool {
        return data.isNull
    }

    public func decode(_ type: Bool.Type) throws -> Bool {
        return try data.assertBool()
    }

    public func decode(_ type: Int.Type) throws -> Int {
        return try data.assertInt()
    }

    public func decode(_ type: Int8.Type) throws -> Int8 {
        return try data.assertInt8()
    }

    public func decode(_ type: Int16.Type) throws -> Int16 {
        return try data.assertInt16()
    }

    public func decode(_ type: Int32.Type) throws -> Int32 {
        return try data.assertInt32()
    }

    public func decode(_ type: Int64.Type) throws -> Int64 {
        return try data.assertInt64()
    }

    public func decode(_ type: UInt.Type) throws -> UInt {
        return try data.assertUInt()
    }

    public func decode(_ type: UInt8.Type) throws -> UInt8 {
        return try data.assertUInt8()
    }

    public func decode(_ type: UInt16.Type) throws -> UInt16 {
        return try data.assertUInt16()
    }

    public func decode(_ type: UInt32.Type) throws -> UInt32 {
        return try data.assertUInt32()
    }

    public func decode(_ type: UInt64.Type) throws -> UInt64 {
        return try data.assertUInt64()
    }

    public func decode(_ type: Float.Type) throws -> Float {
        return try data.assertFloat()
    }

    public func decode(_ type: Double.Type) throws -> Double {
        return try data.assertDouble()
    }

    public func decode(_ type: String.Type) throws -> String {
        return try data.assertString()
    }


    // MARK: Decode Keyed

    public func decodeNil(forKey key: Key) throws -> Bool {
        return get(key: key)?.isNull ?? true
    }

    public func decode(_ type: Bool.Type, forKey key: Key) throws -> Bool {
        return try assertGet(key: key).assertBool()
    }

    public func decode(_ type: Int.Type, forKey key: Key) throws -> Int {
        return try assertGet(key: key).assertInt()
    }

    public func decode(_ type: Int8.Type, forKey key: Key) throws -> Int8 {
        return try assertGet(key: key).assertInt8()
    }

    public func decode(_ type: Int16.Type, forKey key: Key) throws -> Int16 {
        return try assertGet(key: key).assertInt16()
    }

    public func decode(_ type: Int32.Type, forKey key: Key) throws -> Int32 {
        return try assertGet(key: key).assertInt32()
    }

    public func decode(_ type: Int64.Type, forKey key: Key) throws -> Int64 {
        return try assertGet(key: key).assertInt64()
    }

    public func decode(_ type: UInt.Type, forKey key: Key) throws -> UInt {
        return try assertGet(key: key).assertUInt()
    }

    public func decode(_ type: UInt8.Type, forKey key: Key) throws -> UInt8 {
        return try assertGet(key: key).assertUInt8()
    }

    public func decode(_ type: UInt16.Type, forKey key: Key) throws -> UInt16 {
        return try assertGet(key: key).assertUInt16()
    }

    public func decode(_ type: UInt32.Type, forKey key: Key) throws -> UInt32 {
        return try assertGet(key: key).assertUInt32()
    }

    public func decode(_ type: UInt64.Type, forKey key: Key) throws -> UInt64 {
        return try assertGet(key: key).assertUInt64()
    }

    public func decode(_ type: Float.Type, forKey key: Key) throws -> Float {
        return try assertGet(key: key).assertFloat()
    }

    public func decode(_ type: Double.Type, forKey key: Key) throws -> Double {
        return try assertGet(key: key).assertDouble()
    }

    public func decode(_ type: String.Type, forKey key: Key) throws -> String {
        return try assertGet(key: key).assertString()
    }

}


