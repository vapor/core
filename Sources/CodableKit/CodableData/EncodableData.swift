// Data from the `CodableDataEncoder`
public enum EncodableData {
    case null
    case single(EncodableDataCallback)
    case dictionary([String: EncodableData])
    case array([EncodableData])
}

public typealias EncodableDataCallback = (inout SingleValueEncodingContainer) throws -> (Any.Type, [CodingKey])
