// Data from the `CodableDataEncoder`
public enum EncodableData {
    case null
    case encodable(Encodable)
    case dictionary([String: EncodableData])
    case array([EncodableData])
}
