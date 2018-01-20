// Data from the `CodableDataEncoder`
public enum EncodableData {
    case null
    case encode((SingleValueEncodingContainer) throws -> ())
    case dictionary([String: EncodableData])
    case array([EncodableData])
}
