extension Future {
    /// Maps the current future to contain the new type. Errors are carried over, successful (expected) results are transformed into the given instance.
    ///
    /// [Learn More →](https://docs.vapor.codes/3.0/async/promise-future-introduction/#mapping-results)
    public func transform<T>(to instance: T) -> Future<T> {
        return self.map(to: T.self) { _ in
            instance
        }
    }
}

extension Array where Element == Future<Void> {
    /// Transforms a successful future to the supplied value.
    public func transform<T>(on worker: Worker, to callback: @escaping () throws -> Future<T>) -> Future<T> {
        return flatten(on: worker).flatMap(to: T.self, callback)
    }
}
