@available(*, deprecated, renamed: "Future.map(_:_:_:)")
public func map<A, B, Result>(
    to result: Result.Type,
    _ futureA: Future<A>,
    _ futureB: Future<B>,
    _ callback: @escaping (A, B) throws -> (Result)
) -> Future<Result> {
    return futureA.flatMap(to: Result.self) { a in
        return futureB.map(to: Result.self) { b in
            return try callback(a, b)
        }
    }
}

@available(*, deprecated, renamed: "Future.map(_:_:_:_:)")
public func map<A, B, C, Result>(
    to result: Result.Type,
    _ futureA: Future<A>,
    _ futureB: Future<B>,
    _ futureC: Future<C>,
    _ callback: @escaping (A, B, C) throws -> (Result)
) -> Future<Result> {
    return futureA.flatMap(to: Result.self) { a in
        return futureB.flatMap(to: Result.self) { b in
            return futureC.map(to: Result.self) { c in
                return try callback(a, b, c)
            }
        }
    }
}

@available(*, deprecated, renamed: "Future.flatMap(_:_:_:)")
public func flatMap<A, B, Result>(
    to result: Result.Type,
    _ futureA: Future<A>,
    _ futureB: Future<B>,
    _ callback: @escaping (A, B) throws -> (Future<Result>)
) -> Future<Result> {
    return futureA.flatMap(to: Result.self) { a in
        return futureB.flatMap(to: Result.self) { b in
            return try callback(a, b)
        }
    }
}

@available(*, deprecated, renamed: "Future.flatMap(_:_:_:_:)")
public func flatMap<A, B, C, Result>(
    to result: Result.Type,
    _ futureA: Future<A>,
    _ futureB: Future<B>,
    _ futureC: Future<C>,
    _ callback: @escaping (A, B, C) throws -> (Future<Result>)
) -> Future<Result> {
    return futureA.flatMap(to: Result.self) { a in
        return futureB.flatMap(to: Result.self) { b in
            return futureC.flatMap(to: Result.self) { c in
                return try callback(a, b, c)
            }
        }
    }
}

extension Future {
    @available(*, deprecated, renamed: "cascade(promise:)")
    public func chain(to promise: Promise<T>) {
        self.cascade(promise: promise)
    }
}

extension Array where Element == Future<Void> {
    @available(*, deprecated)
    public func transform<T>(on worker: Worker, to callback: @escaping () throws -> Future<T>) -> Future<T> {
        return flatten(on: worker).flatMap(to: T.self, callback)
    }
}
