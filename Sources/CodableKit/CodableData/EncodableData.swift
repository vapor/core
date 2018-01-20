// Data from the `CodableDataEncoder`
public enum EncodableData {
    case null
    case single((inout SingleValueEncodingContainer) throws -> ())
    case dictionary([String: EncodableData])
    case array([EncodableData])
}
