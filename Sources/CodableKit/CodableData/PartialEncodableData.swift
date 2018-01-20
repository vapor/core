/// Reference wrapper around `PartialEncodableData`
public final class PartialEncodableData {
    /// The partial data.
    var data: EncodableData

    /// Creates a new `PartialPostgreSQLData`.
    init(data: EncodableData) {
        self.data = data
    }

    /// Sets the `PostgreSQLData` at supplied coding path.
    func setNil(at path: [CodingKey]) {
        set(&self.data, to: .null, at: path)
    }

    /// Sets the `PostgreSQLData` at supplied coding path.
    func set<E>(_ data: E, at path: [CodingKey]) where E: Encodable {
        set(&self.data, to: .single({ (encoder: inout SingleValueEncodingContainer) in
            try encoder.encode(data)
        }), at: path)
    }

    /// Sets the mutable `PostgreSQLData` to supplied data at coding path.
    private func set(_ context: inout EncodableData, to value: EncodableData, at path: [CodingKey]) {
        guard path.count >= 1 else {
            context = value
            return
        }

        let end = path[0]

        var child: EncodableData?
        switch path.count {
        case 1:
            child = value
        case 2...:
            if let index = end.intValue {
                let array: [EncodableData]
                switch context {
                case .array(let value): array = value
                default: array = []
                }
                if array.count > index {
                    child = array[index]
                } else {
                    child = .array([])
                }
                set(&child!, to: value, at: Array(path[1...]))
            } else {
                let dictionary: [String: EncodableData]
                switch context {
                case .dictionary(let value): dictionary = value
                default: dictionary = [:]
                }
                child = dictionary[end.stringValue] ?? .dictionary([:])
                set(&child!, to: value, at: Array(path[1...]))
            }
        default: break
        }

        if let index = end.intValue {
            if case .array(var arr) = context {
                if arr.count > index {
                    arr[index] = child ?? .null
                } else {
                    arr.append(child ?? .null)
                }
                context = .array(arr)
            } else if let child = child {
                context = .array([child])
            }
        } else {
            if case .dictionary(var dict) = context {
                dict[end.stringValue] = child
                context = .dictionary(dict)
            } else if let child = child {
                context = .dictionary([
                    end.stringValue: child
                    ])
            }
        }
    }
}
