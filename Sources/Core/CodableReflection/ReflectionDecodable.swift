import Foundation

/// Types conforming to this protocol can be created dynamically for use in reflecting the structure of a `Decodable` type.
///
/// `ReflectionDecodable` requires that a type declare two _distinct_ representations of itself. It also requires that the type
/// declare a method for comparing those two representations. If the conforming type is already equatable, this method will
/// not be required.
///
/// A `Bool` is a simple type that is capable of conforming to `ReflectionDecodable`:
///
///     extension Bool: ReflectionDecodable {
///         static func reflectDecoded() -> (Bool, Bool) { return (false, true) }
///     }
///
/// For some types, like an `enum` with only one case, it is impossible to conform to `ReflectionDecodable`. In these situations
/// you must expand the type to have at least two distinct cases, or use a different method of reflection.
///
///     enum Pet { case cat } // unable to conform
///
/// Enums with two or more cases can conform.
///
///     enum Pet { case cat, dog }
///     extension Pet: ReflectionDecodable {
///         static func reflectDecoded() -> (Pet, Pet) { return (.cat, .dog) }
///     }
///
/// Many types already conform to `ReflectionDecodable` such as `String`, `Int`, `Double`, `UUID`, `Array`, `Dictionary`, and `Optional`.
///
/// Other types will have free implementation provided when conformance is added, like `RawRepresentable` types.
///
///     enum Direction: UInt8, ReflectionDecodable {
///         case left, right
///     }
///
public protocol ReflectionDecodable: AnyReflectionDecodable {
    /// Returns a tuple containing two _distinct_ instances for this type.
    ///
    ///     extension Bool: ReflectionDecodable {
    ///         static func reflectDecoded() -> (Bool, Bool) { return (false, true) }
    ///     }
    ///
    /// - throws: Any errors deriving these distinct instances.
    /// - returns: Two distinct instances of this type.
    static func reflectDecoded() -> (Self, Self)

    /// Returns `true` if the supplied instance of this type is equal to the _left_ instance returned
    /// by `reflectDecoded()`.
    ///
    ///     extension Pet: ReflectionDecodable {
    ///         static func reflectDecoded() -> (Pet, Pet) { return (cat, dog) }
    ///     }
    ///
    /// In the case of the above example, this method should return `true` if supplied `Pet.cat` and false for anything else.
    /// This method is automatically implemented for types that conform to `Equatable.
    ///
    /// - throws: Any errors comparing instances.
    /// - returns: `true` if supplied instance equals left side of `reflectDecoded()`.
    static func reflectDecodedIsLeft(_ item: Self) -> Bool
}

/// Type-erased ReflectionDecodable. Do not rely on this protocol.
public protocol AnyReflectionDecodable {
    /// Type-erased `reflectedDecoded()`.
    static func anyReflectDecoded() -> (Any, Any)
    
    /// Type-erased `reflectDecodedIsLeft()`.
    static func anyReflectDecodedIsLeft(_ item: Any) -> Bool

    static var isBaseType: Bool { get }
}

extension AnyReflectionDecodable where Self: ReflectionDecodable {
    /// See `AnyReflectionDecodable`.
    public static func anyReflectDecoded() -> (Any, Any) {
        let (left, right) = reflectDecoded()
        return (left, right)
    }
    
    /// See `AnyReflectionDecodable`.
    public static func anyReflectDecodedIsLeft(_ item: Any) -> Bool {
        return reflectDecodedIsLeft(item as! Self)
    }

    /// Indicates if the value contains any subvalues
    public static var isBaseType: Bool { return true }
}

extension ReflectionDecodable where Self: Equatable {
    /// Default implememntation for `ReflectionDecodable` that are also `Equatable`.
    ///
    /// See `ReflectionDecodable`.
    public static func reflectDecodedIsLeft(_ item: Self) -> Bool {
        return Self.reflectDecoded().0 == item
    }
}

// MARK: Types

extension String: ReflectionDecodable {
    /// See `ReflectionDecodable`.
    public static func reflectDecoded() -> (String, String) { return ("0", "1") }
}

extension FixedWidthInteger {
    /// See `ReflectionDecodable`.
    public static func reflectDecoded() -> (Self, Self) { return (0, 1) }
}

extension UInt: ReflectionDecodable { }
extension UInt8: ReflectionDecodable { }
extension UInt16: ReflectionDecodable { }
extension UInt32: ReflectionDecodable { }
extension UInt64: ReflectionDecodable { }

extension Int: ReflectionDecodable { }
extension Int8: ReflectionDecodable { }
extension Int16: ReflectionDecodable { }
extension Int32: ReflectionDecodable { }
extension Int64: ReflectionDecodable { }

extension Bool: ReflectionDecodable {
    /// See `ReflectionDecodable`.
    public static func reflectDecoded() -> (Bool, Bool) { return (false, true) }
}

extension BinaryFloatingPoint {
    /// See `ReflectionDecodable`.
    public static func reflectDecoded() -> (Self, Self) { return (0, 1) }
}

extension Decimal: ReflectionDecodable {
    /// See `ReflectionDecodable`.
    public static func reflectDecoded() -> (Decimal, Decimal) { return (0, 1) }
}

extension Float: ReflectionDecodable { }
extension Double: ReflectionDecodable { }

extension UUID: ReflectionDecodable {
    /// See `ReflectionDecodable`.
    public static func reflectDecoded() -> (UUID, UUID) {
        let left = UUID(uuid: (0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1))
        let right = UUID(uuid: (0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 2))
        return (left, right)
    }
}

extension Data: ReflectionDecodable {
    /// See `ReflectionDecodable`.
    public static func reflectDecoded() -> (Data, Data) {
        let left = Data([0x00])
        let right = Data([0x01])
        return (left, right)
    }
}

extension Date: ReflectionDecodable {
    /// See `ReflectionDecodable`.
    public static func reflectDecoded() -> (Date, Date) {
        let left = Date(timeIntervalSince1970: 1)
        let right = Date(timeIntervalSince1970: 0)
        return (left, right)
    }
}

extension Array: ReflectionDecodable, AnyReflectionDecodable where Element: ReflectionDecodable {
    /// See `ReflectionDecodable`.
    public static func reflectDecoded() -> ([Element], [Element]) {
        let (left, right) = Element.reflectDecoded()
        return ([left], [right])
    }
    
    /// See `ReflectionDecodable`.
    public static func reflectDecodedIsLeft(_ item: Array<Element>) -> Bool {
        return Element.reflectDecodedIsLeft(item[0])
    }
}

extension Dictionary: ReflectionDecodable, AnyReflectionDecodable where Key: ReflectionDecodable, Value: ReflectionDecodable {
    /// See `ReflectionDecodable`.
    public static func reflectDecoded() -> ([Key: Value], [Key: Value]) {
        let (key, _) = Key.reflectDecoded()
        let (left, right) = Value.reflectDecoded()
        return ([key: left], [key: right])
    }
    
    /// See `ReflectionDecodable`.
    public static func reflectDecodedIsLeft(_ item: [Key: Value]) -> Bool {
        let (key, _) = Key.reflectDecoded()
        return Value.reflectDecodedIsLeft(item[key]!)
    }
}

extension Optional: ReflectionDecodable, AnyReflectionDecodable where Wrapped: ReflectionDecodable {
    /// See `ReflectionDecodable`.
    public static func reflectDecoded() -> (Wrapped?, Wrapped?) {
        let (left, right) = Wrapped.reflectDecoded()
        return (left, right)
    }

    /// See `ReflectionDecodable`.
    public static func reflectDecodedIsLeft(_ item: Wrapped?) -> Bool {
        guard let wrapped = item else {
            return false
        }
        return Wrapped.reflectDecodedIsLeft(wrapped)
    }
}

extension ReflectionDecodable where Self: CaseIterable {
    /// Default implementation of `ReflectionDecodable` for enums that are also `CaseIterable`.
    ///
    /// See `ReflectionDecodable`.
    public static func reflectDecoded() -> (Self, Self) {
        /// enum must have at least 2 unique cases
        guard allCases.count > 1, let first = allCases.first, let last = allCases.suffix(1).first else {
            fatalError("\(Self.self) enum must have at least 2 cases")
        }
        return (first, last)
    }
}
