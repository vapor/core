public extension Future where Expectation: OptionalType {
    /// Unwraps an `Optional` value contained inside a Future's expectation.
    /// If the optional resolves to `nil` (`.none`), the supplied error will be thrown instead.
    ///
    ///     print(futureString) // Future<String?>
    ///     futureString.unwrap(or: MyError()) // Future<String>
    ///
    /// - parameters:
    ///     - error: `Error` to throw if the value is `nil`. This is captured with `@autoclosure`
    ///              to avoid intiailize the `Error` unless needed.
    public func unwrap(or error: @autoclosure @escaping () -> Error) -> Future<Expectation.WrappedType> {
        return map(to: Expectation.WrappedType.self) { optional in
            guard let wrapped = optional.wrapped else {
                throw error()
            }
            return wrapped
        }
    }
}

/// Applies `nil` coalescing to a future's optional and a concrete type.
///
///     print(maybeFutureInt) // Future<Int>?
///     let futureInt = maybeFutureInt ?? 0
///     print(futureInt) // Future<Int>
///
public func ??<T>(lhs: Future<T?>, rhs: T) -> Future<T> {
    return lhs.map(to: T.self) { value in
        return value ?? rhs
    }
}
