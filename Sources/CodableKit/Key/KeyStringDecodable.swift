import Foundation

public protocol AnyKeyStringDecodable {
    static var _keyStringTrue: Any { get }
    static var _keyStringFalse: Any { get }
    static func _keyStringIsTrue(_ any: Any) -> Bool
}

public protocol KeyStringDecodable: AnyKeyStringDecodable {
    static var keyStringTrue: Self { get }
    static var keyStringFalse: Self { get }
    static func keyStringIsTrue(_ item: Self) -> Bool
}

extension KeyStringDecodable {
    public static var _keyStringTrue: Any { return keyStringTrue }
    public static var _keyStringFalse: Any { return keyStringFalse }
    public static func _keyStringIsTrue(_ any: Any) -> Bool {
        return keyStringIsTrue(any as! Self)
    }
}

extension KeyStringDecodable where Self: Equatable {
    public static func keyStringIsTrue(_ item: Self) -> Bool {
        return Self.keyStringTrue == item
    }
}

// MARK: Default Types

extension FixedWidthInteger {
    public static var keyStringTrue: Self { return 1 }
    public static var keyStringFalse: Self { return 0 }
}

extension Int: KeyStringDecodable { }
extension Int8: KeyStringDecodable { }
extension Int16: KeyStringDecodable { }
extension Int32: KeyStringDecodable { }
extension Int64: KeyStringDecodable { }
extension UInt: KeyStringDecodable { }
extension UInt8: KeyStringDecodable { }
extension UInt16: KeyStringDecodable { }
extension UInt32: KeyStringDecodable { }
extension UInt64: KeyStringDecodable { }

extension BinaryFloatingPoint {
    public static var keyStringTrue: Self { return 1 }
    public static var keyStringFalse: Self { return 0 }
}

extension Float: KeyStringDecodable { }
extension Double: KeyStringDecodable { }

extension Data: KeyStringDecodable {
    public static var keyStringTrue: Data { return Data([0x01]) }
    public static var keyStringFalse: Data { return Data([0x00]) }
}

extension String: KeyStringDecodable {
    public static var keyStringTrue: String { return "1" }
    public static var keyStringFalse: String { return "0" }
}

extension Bool: KeyStringDecodable {
    public static var keyStringTrue: Bool { return true }
    public static var keyStringFalse: Bool { return false }
}

extension UUID: KeyStringDecodable {
    public static var keyStringTrue: UUID { return UUID(uuid: (0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1)) }
    public static var keyStringFalse: UUID { return UUID(uuid: (0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 2)) }
}

extension Date: KeyStringDecodable {
    public static var keyStringTrue: Date { return Date(timeIntervalSince1970: 1) }
    public static var keyStringFalse: Date { return Date(timeIntervalSince1970: 0) }
}

extension Array: KeyStringDecodable, AnyKeyStringDecodable {
    public static func keyStringIsTrue(_ item: Array<Element>) -> Bool {
        return requireKeyStringDecodable(Element.self)._keyStringIsTrue(item[0])
    }
    public static var keyStringTrue: Array<Element> {
        return [requireKeyStringDecodable(Element.self)._keyStringTrue as! Element]
    }
    public static var keyStringFalse: Array<Element> {
        return [requireKeyStringDecodable(Element.self)._keyStringFalse as! Element]
    }
}

extension Dictionary: KeyStringDecodable, AnyKeyStringDecodable {
    public static func keyStringIsTrue(_ item: Dictionary<Key, Value>) -> Bool {
        return requireKeyStringDecodable(Value.self)._keyStringIsTrue(item["" as! Key]!)
    }
    public static var keyStringTrue: Dictionary<Key, Value> {
        return ["" as! Key: requireKeyStringDecodable(Value.self)._keyStringTrue as! Value]
    }
    public static var keyStringFalse: Dictionary<Key, Value> {
        return ["" as! Key: requireKeyStringDecodable(Value.self)._keyStringFalse as! Value]
    }
}
extension Optional: KeyStringDecodable, AnyKeyStringDecodable {
    public static func keyStringIsTrue(_ item: Optional<Wrapped>) -> Bool {
        guard let item = item else {
            return false
        }
        return requireKeyStringDecodable(Wrapped.self)._keyStringIsTrue(item)
    }
    public static var keyStringTrue: Optional<Wrapped> {
        return requireKeyStringDecodable(Wrapped.self)._keyStringTrue as? Wrapped
    }
    public static var keyStringFalse: Optional<Wrapped> {
        return requireKeyStringDecodable(Wrapped.self)._keyStringFalse as? Wrapped
    }
}

func requireKeyStringDecodable<T>(_ type: T.Type) -> AnyKeyStringDecodable.Type {
    guard let type = T.self as? AnyKeyStringDecodable.Type else {
        fatalError("\(T.self) does not conform to `KeyStringDecodable`.")
    }
    return type
}
