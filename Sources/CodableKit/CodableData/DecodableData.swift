/// Data from the `CodableDataDecoder`
public enum DecodableData {
    case null
    case single(DecodableDataCallback)
    case dictionary([String: DecodableData])
    case array([DecodableData])
}

public typealias DecodableDataCallback = (Any.Type, [CodingKey]) throws -> (SingleValueDecodingContainer)
