/// Reference wrapper for `PostgreSQLData` being mutated
/// by the PostgreSQL data coders.
final class PartialDecodableData {
    /// The partial data.
    var data: DecodableData

    /// Creates a new `PartialPostgreSQLData`.
    init(data: DecodableData) {
        self.data = data
    }

    /// Returns the value, if one at from the given path.
    func get(at path: [CodingKey]) -> DecodableData? {
        var child = data
        for seg in path {
            switch child {
            case .array(let arr):
                guard let index = seg.intValue, arr.count > index else {
                    return nil
                }
                child = arr[index]
            case .dictionary(let dict):
                guard let value = dict[seg.stringValue] else {
                    return nil
                }
                child = value
            default:
                return nil
            }
        }
        return child
    }

    /// Gets a `nil` from the supplied path or throws a decoding error.
    func decodeNil(at path: [CodingKey]) -> Bool {
        if let value = get(at: path) {
            switch value {
            case .null: return true
            default: return false
            }
        } else {
            return true
        }
    }

    /// Gets a `String` from the supplied path or throws a decoding error.
    func decode<D>(_ type: D.Type = D.self, at path: [CodingKey]) throws -> D where D: Decodable {
        if let value = get(at: path), case .single(let decoder) = value {
            return try decoder(D.self, path).decode(D.self)
        } else {
            let decoder = _CodableDataDecoder(partialData: self, at: path)
            return try D(from: decoder)
        }
    }
}
