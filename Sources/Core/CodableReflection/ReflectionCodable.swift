import Foundation

public protocol AnyReflectionCodable {
    static func anyReflectTrue() throws -> Any
    static func anyReflectFalse() throws -> Any
    static func anyReflectIsTrue(_ any: Any) throws -> Bool
}

public protocol ReflectionCodable: AnyReflectionCodable {
    static func reflectTrue() throws -> Self
    static func reflectFalse() throws -> Self
    static func reflectIsTrue(_ item: Self) throws -> Bool
}

extension ReflectionCodable {
    public static func anyReflectTrue() throws -> Any { return try reflectTrue() }
    public static func anyReflectFalse() throws -> Any { return try reflectFalse() }
    public static func anyReflectIsTrue(_ any: Any) throws -> Bool {
        return try reflectIsTrue(any as! Self)
    }
}

extension ReflectionCodable where Self: Equatable {
    public static func reflectIsTrue(_ item: Self) throws -> Bool {
        return try Self.reflectTrue() == item
    }
}

extension String: ReflectionCodable {
    public static func reflectTrue() -> String { return "1" }
    public static func reflectFalse() -> String { return "0" }
}

extension FixedWidthInteger {
    public static func reflectTrue() -> Self { return 1 }
    public static func reflectFalse() -> Self { return 0 }
}

extension UInt: ReflectionCodable { }
extension UInt8: ReflectionCodable { }
extension UInt16: ReflectionCodable { }
extension UInt32: ReflectionCodable { }
extension UInt64: ReflectionCodable { }

extension Int: ReflectionCodable { }
extension Int8: ReflectionCodable { }
extension Int16: ReflectionCodable { }
extension Int32: ReflectionCodable { }
extension Int64: ReflectionCodable { }

extension Bool: ReflectionCodable {
    public static func reflectTrue() -> Bool { return true }
    public static func reflectFalse() -> Bool { return false }
}

extension BinaryFloatingPoint {
    public static func reflectTrue() -> Self { return 1 }
    public static func reflectFalse() -> Self { return 0 }
}

extension Float: ReflectionCodable { }
extension Double: ReflectionCodable { }

extension UUID: ReflectionCodable {
    public static func reflectTrue() -> UUID { return UUID(uuid: (0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1)) }
    public static func reflectFalse() -> UUID { return UUID(uuid: (0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 2)) }
}

extension Date: ReflectionCodable {
    public static func reflectTrue() -> Date { return Date(timeIntervalSince1970: 1) }
    public static func reflectFalse() -> Date { return Date(timeIntervalSince1970: 0) }
}

extension Optional: ReflectionCodable {
    public static func reflectTrue() throws -> Optional<Wrapped> {
        return try forceCast(Wrapped.self).anyReflectTrue() as? Wrapped
    }
    public static func reflectFalse() throws -> Optional<Wrapped> {
        return try forceCast(Wrapped.self).anyReflectFalse() as? Wrapped
    }
    public static func reflectIsTrue(_ item: Optional<Wrapped>) throws -> Bool {
        guard let wrapped = item else {
            return false
        }
        return try forceCast(Wrapped.self).anyReflectIsTrue(wrapped)
    }
}

extension Array: ReflectionCodable {
    public static func reflectTrue() throws -> [Element] {
        return try [forceCast(Element.self).anyReflectTrue() as! Element]
    }
    public static func reflectFalse() throws -> [Element] {
        return try [forceCast(Element.self).anyReflectFalse() as! Element]
    }
    public static func reflectIsTrue(_ item: [Element]) throws -> Bool {
        return try forceCast(Element.self).anyReflectIsTrue(item[0])
    }
}

extension Dictionary: ReflectionCodable {
    public static func reflectTrue() throws -> [Key: Value] {
        return try [
            forceCast(Key.self).anyReflectTrue() as! Key: forceCast(Value.self).anyReflectTrue() as! Value
        ]
    }
    public static func reflectFalse() throws -> [Key: Value] {
        return try [
            forceCast(Key.self).anyReflectTrue() as! Key: forceCast(Value.self).anyReflectFalse() as! Value
        ]
    }
    public static func reflectIsTrue(_ item: [Key: Value]) throws -> Bool {
        return try forceCast(Value.self).anyReflectIsTrue(item[forceCast(Key.self).anyReflectTrue() as! Key]!)
    }
}

/// this can be removed when conditional conformance actually works
func forceCast<T>(_ type: T.Type) throws -> AnyReflectionCodable.Type {
    guard let casted = T.self as? AnyReflectionCodable.Type else {
        throw CoreError(identifier: "reflectionCodableCast", reason: "Could not cast '\(T.self)' to 'ReflectionCodable'.")
    }
    return casted
}
