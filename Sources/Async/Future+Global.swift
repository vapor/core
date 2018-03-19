// MARK: Convenience
extension Future {
    /// Globally available initializer for mimicking behavior of calling `return future.flatMao`
    /// where no starting future is available.
    ///
    /// This allows you to convert any non-throwing, future-return method into a
    /// closure that accepts throwing and returns a future.
    public static func flatMap(on worker: Worker, _ callback: @escaping () throws -> Future<Expectation>) -> Future<Expectation> {
        let promise = worker.eventLoop.newPromise(Expectation.self)

        do {
            try callback().addAwaiter { result in
                switch result {
                case .error(let error):
                    promise.fail(error: error)
                case .success(let expectation):
                    promise.succeed(result: expectation)
                }
            }
        } catch {
            promise.fail(error: error)
        }

        return promise.futureResult
    }

    /// Globally available initializer for mimicking behavior of calling `return future.flatMao`
    /// where no starting future is available.
    ///
    /// This allows you to convert any non-throwing, future-return method into a
    /// closure that accepts throwing and returns a future.
    public static func map(on worker: Worker, _ callback: @escaping () throws -> Expectation) -> Future<Expectation> {
        let promise = worker.eventLoop.newPromise(Expectation.self)

        do {
            try promise.succeed(result: callback())
        } catch {
            promise.fail(error: error)
        }

        return promise.futureResult
    }
}
