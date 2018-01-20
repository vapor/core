/// Internal `SingleValueEncodingContainer` for `CodableDataEncoder`.
internal final class CodableDataSingleValueEncodingContainer: SingleValueEncodingContainer {
    /// See `KeyedEncodingContainerProtocol.codingPath`
    var codingPath: [CodingKey]

    /// Data being encoded.
    let partialData: PartialEncodableData

    /// Creates a new `CodableDataKeyedEncodingContainer`
    init(partialData: PartialEncodableData, at path: [CodingKey]) {
        self.codingPath = path
        self.partialData = partialData
    }

    /// See `SingleValueEncodingContainer.encodeNil`
    func encodeNil() throws {
        partialData.setNil(at: codingPath)
    }

    /// See `SingleValueEncodingContainer.encode`
    func encode(_ value: Bool) throws {
        partialData.set(value, at: codingPath)
    }

    /// See `SingleValueEncodingContainer.encode`
    func encode(_ value: Int) throws {
        partialData.set(value, at: codingPath)
    }

    /// See `SingleValueEncodingContainer.encode`
    func encode(_ value: Int8) throws {
        partialData.set(value, at: codingPath)
    }

    /// See `SingleValueEncodingContainer.encode`
    func encode(_ value: Int16) throws {
        partialData.set(value, at: codingPath)
    }

    /// See `SingleValueEncodingContainer.encode`
    func encode(_ value: Int32) throws {
        partialData.set(value, at: codingPath)
    }

    /// See `SingleValueEncodingContainer.encode`
    func encode(_ value: Int64) throws {
        partialData.set(value, at: codingPath)
    }

    /// See `SingleValueEncodingContainer.encode`
    func encode(_ value: UInt) throws {
        partialData.set(value, at: codingPath)
    }

    /// See `SingleValueEncodingContainer.encode`
    func encode(_ value: UInt8) throws {
        partialData.set(value, at: codingPath)
    }

    /// See `SingleValueEncodingContainer.encode`
    func encode(_ value: UInt16) throws {
        partialData.set(value, at: codingPath)
    }

    /// See `SingleValueEncodingContainer.encode`
    func encode(_ value: UInt32) throws {
        partialData.set(value, at: codingPath)
    }

    /// See `SingleValueEncodingContainer.encode`
    func encode(_ value: UInt64) throws {
        partialData.set(value, at: codingPath)
    }

    /// See `SingleValueEncodingContainer.encode`
    func encode(_ value: Float) throws {
        partialData.set(value, at: codingPath)
    }

    /// See `SingleValueEncodingContainer.encode`
    func encode(_ value: Double) throws {
        partialData.set(value, at: codingPath)
    }

    /// See `SingleValueEncodingContainer.encode`
    func encode(_ value: String) throws {
        partialData.set(value, at: codingPath)
    }

    /// See `SingleValueEncodingContainer.encode`
    func encode<T>(_ value: T) throws where T : Encodable {
        partialData.set(value, at: codingPath)
    }

    /// See `SingleValueEncodingContainer.nestedContainer`
    func nestedContainer<NestedKey>(keyedBy keyType: NestedKey.Type) -> KeyedEncodingContainer<NestedKey>
        where NestedKey: CodingKey
    {
        let container = CodableDataKeyedEncodingContainer<NestedKey>(partialData: partialData, at: codingPath)
        return .init(container)
    }

    /// See `SingleValueEncodingContainer.nestedSingleValueContainer`
    func nestedUnkeyedContainer() -> UnkeyedEncodingContainer {
        return CodableDataUnkeyedEncodingContainer(partialData: partialData, at: codingPath)
    }

    /// See `SingleValueEncodingContainer.superEncoder`
    func superEncoder() -> Encoder {
        return _CodableDataEncoder(partialData: partialData, at: codingPath)
    }
}

