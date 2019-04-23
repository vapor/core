extension Collection {
    /// Maps a collection of same-type `Future`s.
    ///
    /// See `Future.map`
    public func map<S, T>(to type: T.Type, on worker: Worker, _ callback: @escaping ([S]) throws -> T) -> Future<T> where Element == Future<S> {
        return flatten(on: worker).map(to: T.self, callback)
    }

    /// Maps a collection of same-type `Future`s.
    ///
    /// See `Future.flatMap`
    public func flatMap<S, T>(to type: T.Type, on worker: Worker, _ callback: @escaping ([S]) throws -> Future<T>) -> Future<T> where Element == Future<S> {
        return flatten(on: worker).flatMap(to: T.self, callback)
    }
}

extension Collection where Element == Future<Void> {
    /// Maps a collection of void `Future`s.
    ///
    /// See `Future.map`
    public func map<T>(to type: T.Type, on worker: Worker, _ callback: @escaping () throws -> T) -> Future<T> {
        return flatten(on: worker).map(to: T.self) { _ in
            return try callback()
        }
    }

    /// Maps a collection of void `Future`s.
    ///
    /// See `Future.flatMap`
    public func flatMap<T>(to type: T.Type, on worker: Worker, _ callback: @escaping () throws -> Future<T>) -> Future<T> {
        return flatten(on: worker).flatMap(to: T.self) { _ in
            return try callback()
        }
    }
}
