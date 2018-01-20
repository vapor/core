/// Data from the `CodableDataDecoder`
public enum DecodableData {
    case null
    case decode(() throws -> (SingleValueDecodingContainer))
    case dictionary([String: DecodableData])
    case array([DecodableData])
}
