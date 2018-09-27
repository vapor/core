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
    static func reflectDecoded() throws -> (Self, Self)

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
    static func reflectDecodedIsLeft(_ item: Self) throws -> Bool
}

extension ReflectionDecodable where Self: Equatable {
    /// Default implememntation for `ReflectionDecodable` that are also `Equatable`.
    ///
    /// See `ReflectionDecodable.reflectDecodedIsLeft(_:)` for more information.
    public static func reflectDecodedIsLeft(_ item: Self) throws -> Bool {
        return try Self.reflectDecoded().0 == item
    }
}

// MARK: Types

extension String: ReflectionDecodable {
    /// See `ReflectionDecodable.reflectDecoded()` for more information.
    public static func reflectDecoded() -> (String, String) { return ("0", "1") }
}

extension FixedWidthInteger {
    /// See `ReflectionDecodable.reflectDecoded()` for more information.
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
    /// See `ReflectionDecodable.reflectDecoded()` for more information.
    public static func reflectDecoded() -> (Bool, Bool) { return (false, true) }
}

extension BinaryFloatingPoint {
    /// See `ReflectionDecodable.reflectDecoded()` for more information.
    public static func reflectDecoded() -> (Self, Self) { return (0, 1) }
}

extension Decimal: ReflectionDecodable {
    /// See `ReflectionDecodable.reflectDecoded()` for more information.
    public static func reflectDecoded() -> (Decimal, Decimal) { return (0, 1) }
}

extension Float: ReflectionDecodable { }
extension Double: ReflectionDecodable { }

extension UUID: ReflectionDecodable {
    /// See `ReflectionDecodable.reflectDecoded()` for more information.
    public static func reflectDecoded() -> (UUID, UUID) {
        let left = UUID(uuid: (0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1))
        let right = UUID(uuid: (0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 2))
        return (left, right)
    }
}

extension Data: ReflectionDecodable {
    /// See `ReflectionDecodable.reflectDecoded()` for more information.
    public static func reflectDecoded() -> (Data, Data) {
        let left = Data([0x00])
        let right = Data([0x01])
        return (left, right)
    }
}

extension Date: ReflectionDecodable {
    /// See `ReflectionDecodable.reflectDecoded()` for more information.
    public static func reflectDecoded() -> (Date, Date) {
        let left = Date(timeIntervalSince1970: 1)
        let right = Date(timeIntervalSince1970: 0)
        return (left, right)
    }
}

extension Optional: ReflectionDecodable {
    /// See `ReflectionDecodable.reflectDecoded()` for more information.
    public static func reflectDecoded() throws -> (Wrapped?, Wrapped?) {
        let reflected = try forceCast(Wrapped.self).anyReflectDecoded()
        return (reflected.0 as? Wrapped, reflected.1 as? Wrapped)
    }

    /// See `ReflectionDecodable.reflectDecodedIsLeft(_:)` for more information.
    public static func reflectDecodedIsLeft(_ item: Wrapped?) throws -> Bool {
        guard let wrapped = item else {
            return false
        }
        return try forceCast(Wrapped.self).anyReflectDecodedIsLeft(wrapped)
    }
}

extension Array: ReflectionDecodable {
    /// See `ReflectionDecodable.reflectDecoded()` for more information.
    public static func reflectDecoded() throws -> ([Element], [Element]) {
        let reflected = try forceCast(Element.self).anyReflectDecoded()
        return ([reflected.0 as! Element], [reflected.1 as! Element])
    }

    /// See `ReflectionDecodable.reflectDecodedIsLeft(_:)` for more information.
    public static func reflectDecodedIsLeft(_ item: [Element]) throws -> Bool {
        return try forceCast(Element.self).anyReflectDecodedIsLeft(item[0])
    }
}

extension Dictionary: ReflectionDecodable {
    /// See `ReflectionDecodable.reflectDecoded()` for more information.
    public static func reflectDecoded() throws -> ([Key: Value], [Key: Value]) {
        let reflectedValue = try forceCast(Value.self).anyReflectDecoded()
        let reflectedKey = try forceCast(Key.self).anyReflectDecoded()
        let key = reflectedKey.0 as! Key
        return ([key: reflectedValue.0 as! Value], [key: reflectedValue.1 as! Value])
    }

    /// See `ReflectionDecodable.reflectDecodedIsLeft(_:)` for more information.
    public static func reflectDecodedIsLeft(_ item: [Key: Value]) throws -> Bool {
        let reflectedKey = try forceCast(Key.self).anyReflectDecoded()
        let key = reflectedKey.0 as! Key
        return try forceCast(Value.self).anyReflectDecodedIsLeft(item[key]!)
    }
}

extension URL: ReflectionDecodable {
    /// See `ReflectionDecodable.reflectDecoded()` for more information.
    public static func reflectDecoded() throws -> (URL, URL) {
        let left = URL(string: "https://left.fake.url")!
        let right = URL(string: "https://right.fake.url")!
        return (left, right)
    }
}

// MARK: Type Erased

/// Type-erased version of `ReflectionDecodable`
public protocol AnyReflectionDecodable {
    /// Type-erased version of `ReflectionDecodable.reflectDecoded()`.
    ///
    /// See `ReflectionDecodable.reflectDecoded()` for more information.
    static func anyReflectDecoded() throws -> (Any, Any)

    /// Type-erased version of `ReflectionDecodable.reflectDecodedIsLeft(_:)`.
    ///
    /// See `ReflectionDecodable.reflectDecodedIsLeft(_:)` for more information.
    static func anyReflectDecodedIsLeft(_ any: Any) throws -> Bool
}

extension ReflectionDecodable {
    /// Type-erased version of `ReflectionDecodable.reflectDecoded()`.
    ///
    /// See `ReflectionDecodable.reflectDecoded()` for more information.
    public static func anyReflectDecoded() throws -> (Any, Any) {
        let reflected = try reflectDecoded()
        return (reflected.0, reflected.1)
    }

    /// Type-erased version of `ReflectionDecodable.reflectDecodedIsLeft(_:)`.
    ///
    /// See `ReflectionDecodable.reflectDecodedIsLeft(_:)` for more information.
    public static func anyReflectDecodedIsLeft(_ any: Any) throws -> Bool {
        return try reflectDecodedIsLeft(any as! Self)
    }
}

/// Trys to cast a type to `AnyReflectionDecodable.Type`. This can be removed when conditional conformance supports runtime querying.
func forceCast<T>(_ type: T.Type) throws -> AnyReflectionDecodable.Type {
    guard let casted = T.self as? AnyReflectionDecodable.Type else {
        throw CoreError(
            identifier: "ReflectionDecodable",
            reason: "\(T.self) is not `ReflectionDecodable`",
            suggestedFixes: [
                "Conform `\(T.self)` to `ReflectionDecodable`: `extension \(T.self): ReflectionDecodable { }`."
            ]
        )
    }
    return casted
}

#if swift(>=4.1.50)
#else
public protocol CaseIterable {
    static var allCases: [Self] { get }
}
#endif

extension ReflectionDecodable where Self: CaseIterable {
    /// Default implementation of `ReflectionDecodable` for enums that are also `CaseIterable`.
    ///
    /// See `ReflectionDecodable.reflectDecoded(_:)` for more information.
    public static func reflectDecoded() throws -> (Self, Self) {
        /// enum must have at least 2 unique cases
        guard allCases.count > 1,
            let first = allCases.first, let last = allCases.suffix(1).first else {
                throw CoreError(
                    identifier: "ReflectionDecodable",
                    reason: "\(Self.self) enum must have at least 2 cases",
                    suggestedFixes: [
                        "Add at least 2 cases to the enum."
                    ]
                )
        }
        return (first, last)
    }
}
