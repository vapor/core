public enum CodableData {
    case string(String)
    case bool(Bool)

    case int(Int)
    case int8(Int8)
    case int16(Int16)
    case int32(Int32)
    case int64(Int64)

    case uint(UInt)
    case uint8(UInt8)
    case uint16(UInt16)
    case uint32(UInt32)
    case uint64(UInt64)

    case float(Float)
    case double(Double)

    /// stores any T encodables
    case encodable(Encodable)

    /// pass a decoder to use instead
    case decoder(Decoder)

    case dictionary([String: CodableData])
    case array([CodableData])

    case null
}

// Data from the `CodableDataEncoder`
public enum EncodableData {
    case null
    case encodable(Encodable)
    case dictionary([String: EncodableData])
    case array([EncodableData])
}

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
    func set(_ data: Encodable, at path: [CodingKey]) {
        set(&self.data, to: .encodable(data), at: path)
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

extension CodableData: Equatable {
    /// See Equatable.==
    public static func ==(lhs: CodableData, rhs: CodableData) -> Bool {
        switch (lhs, rhs) {
        case (.string(let a), .string(let b)): return a == b
        case (.int(let a), .int(let b)): return a == b
        case (.int8(let a), .int8(let b)): return a == b
        case (.int16(let a), .int16(let b)): return a == b
        case (.int32(let a), .int32(let b)): return a == b
        case (.int64(let a), .int64(let b)): return a == b
        case (.uint(let a), .uint(let b)): return a == b
        case (.uint8(let a), .uint8(let b)): return a == b
        case (.uint16(let a), .uint16(let b)): return a == b
        case (.uint32(let a), .uint32(let b)): return a == b
        case (.uint64(let a), .uint64(let b)): return a == b
        case (.float(let a), .float(let b)): return a == b
        case (.double(let a), .double(let b)): return a == b
        case (.dictionary(let a), .dictionary(let b)): return a == b
        case (.array(let a), .array(let b)): return a == b
        case (.null, .null): return true
        default: return false
        }
    }
}

extension CodableData {
    var array: [CodableData]? {
        switch self {
        case .array(let value): return value
        default: return nil
        }
    }

    var dictionary: [String: CodableData]? {
        switch self {
        case .dictionary(let value): return value
        default: return nil
        }
    }
}
