import Foundation

public final class PolymorphicDecoder<Data: Polymorphic>: Decoder {
    public var codingPath: [CodingKey]
    public var userInfo: [CodingUserInfoKey : Any]
    private var data: Data

    public typealias CodingKeyMap = (CodingKey) -> (CodingKey)
    public var codingKeyMap: (CodingKey) -> (CodingKey)

    public init(
        data: Data,
        codingPath: [CodingKey],
        codingKeyMap: @escaping CodingKeyMap,
        userInfo: [CodingUserInfoKey: Any]
    ) {
        self.codingPath = codingPath
        self.data = data
        self.codingKeyMap = codingKeyMap
        self.userInfo = userInfo
    }

    func duplicate(with data: Data) -> PolymorphicDecoder<Data> {
        return PolymorphicDecoder<Data>(
            data: data,
            codingPath: codingPath,
            codingKeyMap: codingKeyMap,
            userInfo: userInfo
        )
    }

    func with<T>(pushedKey key: CodingKey, _ work: () throws -> T) rethrows -> T {
        self.codingPath.append(key)
        let ret: T = try work()
        self.codingPath.removeLast()
        return ret
    }

    public func container<Key>(
        keyedBy type: Key.Type
    ) throws -> KeyedDecodingContainer<Key> where Key : CodingKey {
        let cont = PolymorphicContainer<Data, Key>(decoder: self, mode: .keyed, data: data)
        return KeyedDecodingContainer(cont)
    }

    public func unkeyedContainer() throws -> UnkeyedDecodingContainer {
        return PolymorphicContainer<Data, StringKey>(decoder: self, mode: .unkeyed, data: data)
    }

    public func singleValueContainer() throws -> SingleValueDecodingContainer {
        return PolymorphicContainer<Data, StringKey>(decoder: self, mode: .single, data: data)
    }
}
