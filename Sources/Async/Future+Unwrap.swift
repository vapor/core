public extension Future where Expectation: OptionalType {
    /// Unwraps an optional value contained inside a Future's expectation.
    /// If the optional resolves to `nil` (`.none`), the supplied error will be thrown instead.
    public func unwrap(or error: Error) -> Future<Expectation.WrappedType> {
        return map(to: Expectation.WrappedType.self) { optional in
            guard let wrapped = optional.wrapped else {
                throw error
            }
            return wrapped
        }
    }
}

/// Capable of being represented by an optional wrapped type.
///
/// This protocol mostly exists to allow constrained extensions on generic
/// types where an associatedtype is an `Optional<T>`.
public protocol OptionalType {
    /// Underlying wrapped type.
    associatedtype WrappedType

    /// Returns the wrapped type, if it exists.
    var wrapped: WrappedType? { get }

    /// Creates this optional type from an optional wrapped type.
    static func makeOptionalType(_ wrapped: WrappedType?) -> Self
}

/// Conform concrete optional to `OptionalType`.
/// See `OptionalType` for more information.
extension Optional: OptionalType {
    /// See `OptionalType.WrappedType`
    public typealias WrappedType = Wrapped

    /// See `OptionalType.wrapped`
    public var wrapped: Wrapped? {
        switch self {
        case .none: return nil
        case .some(let w): return w
        }
    }

    /// See `OptionalType.makeOptionalType`
    public static func makeOptionalType(_ wrapped: Wrapped?) -> Optional<Wrapped> {
        return wrapped
    }
}
