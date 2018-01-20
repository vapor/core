/// Data from the `CodableDataDecoder`
public enum DecodableData {
    case null
    case decoder(SingleValueDecodingContainer)
    case dictionary([String: DecodableData])
    case array([DecodableData])
}
