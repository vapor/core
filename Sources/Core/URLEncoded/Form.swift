/// Supported data types for storing
// and fetching from a `Cache`.
internal enum URLEncodedForm {
    case string(String)
    case array([URLEncodedForm])
    case dictionary([String: URLEncodedForm])
    case null
}

extension URLEncodedForm: Polymorphic {
    var string: String? {
        switch self {
        case .string(let string):
            return string
        default:
            return nil
        }
    }

    var int: Int? {
        return string?.int
    }

    var double: Double? {
        return string?.double
    }

    var bool: Bool? {
        return string?.bool
    }

    var dictionary: [String : URLEncodedForm]? {
        switch self {
        case .dictionary(let dict):
            return dict
        default:
            return nil
        }
    }

    var array: [URLEncodedForm]? {
        switch self {
        case .array(let arr):
            return arr
        default:
            return nil
        }
    }

    var isNull: Bool {
        switch self {
        case .null:
            return true
        case .string(let string):
            return string.isNull
        default:
            return false
        }
    }
}
