extension Promise where T == Void {
    /// Calls `succeed(result: ())`.
    public func succeed() {
        self.succeed(result: ())
    }
}

extension Future where T == Void {
    /// A pre-completed `Future<Void>`.
    public static func done(on worker: Worker) -> Future<T> {
        let promise = worker.eventLoop.newPromise(Void.self)
        promise.succeed()
        return promise.futureResult
    }
}

extension Future where T == Void {
    /// Convenience function for returning void inside a future
    public static var void: Void {
        return _void
    }
}

private let _void: Void = {}()
