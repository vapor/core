// This file conforms common types from the standard
// library to be polymorphic.

extension String: Polymorphic {
    public var string: String? { return self }
    public var int: Int? { return Int(self) }
    public var uint: UInt? { return UInt(self) }
    public var double: Double? { return Double(self) }
    public var bool: Bool? { return Bool(self) }
    public var dictionary: [String : String]? { return nil }
    public var array: [String]? { return nil }
    public var isNull: Bool {
        switch self {
        case "null", "NULL":
            return true
        default:
            return false
        }
    }
}

extension Int: Polymorphic {
    public var string: String? { return String(self) }
    public var int: Int? { return self }
    public var double: Double? { return Double(self) }
    public var bool: Bool? {
        switch self {
        case 1:
            return true
        case 0:
            return false
        default:
            return nil
        }
    }
    public var dictionary: [String: Int]? { return nil }
    public var array: [Int]? { return nil }
    public var isNull: Bool { return false }
}

extension Double: Polymorphic {
    public var string: String? { return String(self) }
    public var int: Int? { return Int(self) }
    public var uint: UInt? { return UInt(self) }
    public var double: Double? { return self }
    public var bool: Bool? {
        switch self {
        case 1:
            return true
        case 0:
            return false
        default:
            return nil
        }
    }
    public var dictionary: [String: Double]? { return nil }
    public var array: [Double]? { return nil }
    public var isNull: Bool { return false }
}
