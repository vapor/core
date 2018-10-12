// MARK: Transform

extension Future {
    /// Maps the current future to contain the new type. Errors are carried over, successful (expected) results are transformed into the given instance.
    ///
    ///     user.save(on: req).transform(to: HTTPStatus.created)
    ///
    public func transform<T>(to instance: T) -> Future<T> {
        return self.map(to: T.self) { _ in
            instance
        }
    }
    
    /// Maps the current future to contain the new type, ignoring errors.
    ///
    ///     user.save(on: req).transformAlways(to: HTTPStatus.ok)
    public func transformAlways<T>(to instance: T) -> Future<T> {
        return self.map(to: T.self) { _ in
            instance
        }.catchMap { _ in
            instance
        }
    }
}
