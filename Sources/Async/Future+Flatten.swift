/// A closure that returns a future.
public typealias LazyFuture<T> = () -> (Future<T>)

extension Collection where Element == LazyFuture<Void> {
    /// Flattens an array of lazy futures into a future with an array of results.
    /// - note: each subsequent future will wait for the previous to complete before starting.
    public func syncFlatten(on worker: Worker) -> Future<Void> {
        let promise = worker.eventLoop.newPromise(Void.self)

        var iterator = makeIterator()
        func handle(_ future: LazyFuture<Void>) {
            future().do { res in
                if let next = iterator.next() {
                    handle(next)
                } else {
                    promise.succeed()
                }
            }.catch { error in
                promise.fail(error: error)
            }
        }

        if let first = iterator.next() {
            handle(first)
        } else {
            promise.succeed()
        }

        return promise.futureResult
    }
}

extension Collection where Element: FutureType {
    /// Flattens an array of futures into a future with an array of results.
    /// - note: the order of the results will match the order of the futures in the input array.
    public func flatten(on worker: Worker) -> Future<[Element.Expectation]> {
        var elements: [Element.Expectation] = []

        let promise = worker.eventLoop.newPromise([Element.Expectation].self)
        guard count > 0 else {
            promise.succeed(result: elements)
            return promise.futureResult
        }

        elements.reserveCapacity(self.count)

        for element in self {
            element.addAwaiter { result in
                switch result {
                case .error(let error): promise.fail(error: error)
                case .success(let expectation):
                    elements.append(expectation)

                    if elements.count == self.count {
                        promise.succeed(result: elements)
                    }
                }
            }
        }

        return promise.futureResult
    }
}

extension Collection where Element == Future<Void> {
    /// Flattens an array of void futures into a single one.
    public func flatten(on worker: Worker) -> Future<Void> {
        let flatten: Future<[Void]> = self.flatten(on: worker)
        return flatten.map(to: Void.self) { _ in return }
    }
}
