public extension Future where Expectation: OptionalType {
    /// Unwraps an optional value contained inside a Future's expectation.
    /// If the optional resolves to `nil` (`.none`), the supplied error will be thrown instead.
    public func unwrap(or error: @autoclosure @escaping () -> Error) -> Future<Expectation.WrappedType> {
        return map(to: Expectation.WrappedType.self) { optional in
            guard let wrapped = optional.wrapped else {
                throw error()
            }
            return wrapped
        }
    }
}
