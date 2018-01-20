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
