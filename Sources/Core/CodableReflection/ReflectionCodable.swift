/// Types conforming to this protocol can be created dynamically for use in reflecting the structure of a `Decodable` type.
///
/// `ReflectionCodable` requires that a type declare two, _distinct_ representations of itself. It also requires that the type
/// declare a method for comparing those two representations. If the conforming type is already equatable, this method will
/// not be required.
///
/// A `Bool` is a simple type that is capable of conforming to `ReflectionCodable`:
///
///     extension Bool: ReflectionCodable {
///         static func reflectCodable() -> (Bool, Bool) { return (false, true) }
///     }
///
/// For some types, like an `enum` with only one case, it is impossible to conform to `ReflectionCodable`. In these situations
/// you must expand the type to have at least two distinct cases, or use a different method of reflection.
///
///     enum Pet { case cat } // unable to conform
///
/// Enums with two or more cases can conform.
///
///     enum Pet { case cat, dog }
///     extension Pet: ReflectionCodable {
///         static func reflectCodable() -> (Pet, Pet) { return (.cat, .dog) }
///     }
///
/// Many types already conform to `ReflectionCodable` such as `String`, `Int`, `Double`, `UUID`, `Array`, `Dictionary`, and `Optional`.
///
/// Other types will have free implementation provided when conformance is added, like `RawRepresentable` types.
///
///     enum Direction: UInt8, ReflectionCodable {
///         case left, right
///     }
///
public protocol ReflectionCodable: AnyReflectionCodable {
    /// Returns a tuple containing two, _distinct_ instances for this type.
    ///
    ///     extension Bool: ReflectionCodable {
    ///         static func reflectCodable() -> (Bool, Bool) { return (false, true) }
    ///     }
    ///
    /// - throws: Any errors deriving these distinct instances.
    /// - returns: Two distinct instances of this type.
    static func reflectCodable() throws -> (Self, Self)

    /// Returns `true` if the supplied instance of this type is equal to the _left_ type returned
    /// by `reflectCodable()`.
    ///
    ///     extension Pet: ReflectionCodable {
    ///         static func reflectCodable() -> (Pet, Pet) { return (cat, dog) }
    ///     }
    ///
    /// In the case of the above example, this method should return `true` if supplied `Pet.cat`.
    /// This method is automatically implemented for types that conform to `Equatable.
    ///
    /// - throws: Any errors comparing instances.
    /// - returns: `True` if supplied instance equals left side of `reflectCodable()`.
    static func reflectCodableIsLeft(_ item: Self) throws -> Bool
}

extension ReflectionCodable where Self: Equatable {
    /// Default implememntation for `ReflectionCodable` that are also `Equatable`.
    ///
    /// See `ReflectionCodable.reflectCodableIsLeft(_:)` for more information.
    public static func reflectCodableIsLeft(_ item: Self) throws -> Bool {
        return try Self.reflectCodable().0 == item
    }
}

// MARK: Types

extension String: ReflectionCodable {
    /// See `ReflectionCodable.reflectCodable()` for more information.
    public static func reflectCodable() -> (String, String) { return ("0", "1") }
}

extension FixedWidthInteger {
    /// See `ReflectionCodable.reflectCodable()` for more information.
    public static func reflectCodable() -> (Self, Self) { return (0, 1) }
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
    /// See `ReflectionCodable.reflectCodable()` for more information.
    public static func reflectCodable() -> (Bool, Bool) { return (false, true) }
}

extension BinaryFloatingPoint {
    /// See `ReflectionCodable.reflectCodable()` for more information.
    public static func reflectCodable() -> (Self, Self) { return (0, 1) }
}

extension Float: ReflectionCodable { }
extension Double: ReflectionCodable { }

extension UUID: ReflectionCodable {
    /// See `ReflectionCodable.reflectCodable()` for more information.
    public static func reflectCodable() -> (UUID, UUID) {
        let left = UUID(uuid: (0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1))
        let right = UUID(uuid: (0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 2))
        return (left, right)
    }
}

extension Date: ReflectionCodable {
    /// See `ReflectionCodable.reflectCodable()` for more information.
    public static func reflectCodable() -> (Date, Date) {
        let left = Date(timeIntervalSince1970: 1)
        let right = Date(timeIntervalSince1970: 0)
        return (left, right)
    }
}

extension Optional: ReflectionCodable {
    /// See `ReflectionCodable.reflectCodable()` for more information.
    public static func reflectCodable() throws -> (Wrapped?, Wrapped?) {
        let reflected = try forceCast(Wrapped.self).anyReflectCodable()
        return (reflected.0 as? Wrapped, reflected.1 as? Wrapped)
    }

    /// See `ReflectionCodable.reflectCodableIsLeft(_:)` for more information.
    public static func reflectCodableIsLeft(_ item: Wrapped?) throws -> Bool {
        guard let wrapped = item else {
            return false
        }
        return try forceCast(Wrapped.self).anyReflectCodableIsLeft(wrapped)
    }
}

extension Array: ReflectionCodable {
    /// See `ReflectionCodable.reflectCodable()` for more information.
    public static func reflectCodable() throws -> ([Element], [Element]) {
        let reflected = try forceCast(Element.self).anyReflectCodable()
        return ([reflected.0 as! Element], [reflected.1 as! Element])
    }

    /// See `ReflectionCodable.reflectCodableIsLeft(_:)` for more information.
    public static func reflectCodableIsLeft(_ item: [Element]) throws -> Bool {
        return try forceCast(Element.self).anyReflectCodableIsLeft(item[0])
    }
}

extension Dictionary: ReflectionCodable {
    /// See `ReflectionCodable.reflectCodable()` for more information.
    public static func reflectCodable() throws -> ([Key: Value], [Key: Value]) {
        let reflectedValue = try forceCast(Value.self).anyReflectCodable()
        let reflectedKey = try forceCast(Key.self).anyReflectCodable()
        let key = reflectedKey.0 as! Key
        return ([key: reflectedValue.0 as! Value], [key: reflectedValue.1 as! Value])
    }

    /// See `ReflectionCodable.reflectCodableIsLeft(_:)` for more information.
    public static func reflectCodableIsLeft(_ item: [Key: Value]) throws -> Bool {
        let reflectedKey = try forceCast(Key.self).anyReflectCodable()
        let key = reflectedKey.0 as! Key
        return try forceCast(Value.self).anyReflectCodableIsLeft(item[key]!)
    }
}

extension RawRepresentable where RawValue: FixedWidthInteger {
    /// See `ReflectionCodable.reflectCodable()` for more information.
    public static func reflectCodable() throws -> (Self, Self) {
        let reflected = RawValue.reflectCodable()
        guard let left = self.init(rawValue: reflected.0), let right = self.init(rawValue: reflected.1) else {
            throw CoreError(
                identifier: "reflectRawValue",
                reason: "Could not create `\(Self.self)` from default values.",
                possibleCauses: ["This enum is using custom raw values (using = to declare value for enum cases."],
                suggestedFixes: ["Implement `static func reflectCodable()` manually."]
            )
        }
        return (left, right)
    }
}

// MARK: Type Erased

/// Type-erased version of `ReflectionCodable`
public protocol AnyReflectionCodable {
    /// Type-erased version of `ReflectionCodable.reflectCodable()`.
    ///
    /// See `ReflectionCodable.reflectCodable()` for more information.
    static func anyReflectCodable() throws -> (Any, Any)

    /// Type-erased version of `ReflectionCodable.reflectCodableIsLeft(_:)`.
    ///
    /// See `ReflectionCodable.reflectCodableIsLeft(_:)` for more information.
    static func anyReflectCodableIsLeft(_ any: Any) throws -> Bool
}

extension ReflectionCodable {
    /// Type-erased version of `ReflectionCodable.reflectCodable()`.
    ///
    /// See `ReflectionCodable.reflectCodable()` for more information.
    public static func anyReflectCodable() throws -> (Any, Any) {
        let reflected = try reflectCodable()
        return (reflected.0, reflected.1)
    }

    /// Type-erased version of `ReflectionCodable.reflectCodableIsLeft(_:)`.
    ///
    /// See `ReflectionCodable.reflectCodableIsLeft(_:)` for more information.
    public static func anyReflectCodableIsLeft(_ any: Any) throws -> Bool {
        return try reflectCodableIsLeft(any as! Self)
    }
}

/// Trys to cast a type to `AnyReflectionCodable.Type`. This can be removed when conditional conformance supports runtime querying.
func forceCast<T>(_ type: T.Type) throws -> AnyReflectionCodable.Type {
    guard let casted = T.self as? AnyReflectionCodable.Type else {
        throw CoreError(identifier: "reflectionCodableCast", reason: "Could not cast '\(T.self)' to 'ReflectionCodable'.")
    }
    return casted
}
