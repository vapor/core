// MARK: Flatten

/// A closure that returns a future.
public typealias LazyFuture<T> = () throws -> Future<T>

extension Collection {
    /// Flattens an array of lazy futures into a future with an array of results.
    /// - note: each subsequent future will wait for the previous to complete before starting.
    public func syncFlatten<T>(on worker: Worker) -> Future<[T]> where Element == LazyFuture<T> {
        let promise = worker.eventLoop.newPromise([T].self)
        
        var elements: [T] = []
        elements.reserveCapacity(self.count)
        
        var iterator = makeIterator()
        func handle(_ future: LazyFuture<T>) {
            do {
                try future().do { res in
                    elements.append(res)
                    if let next = iterator.next() {
                        handle(next)
                    } else {
                        promise.succeed(result: elements)
                    }
                }.catch { error in
                    promise.fail(error: error)
                }
            } catch {
                promise.fail(error: error)
            }
        }

        if let first = iterator.next() {
            handle(first)
        } else {
            promise.succeed(result: elements)
        }

        return promise.futureResult
    }
}

extension Collection where Element == LazyFuture<Void> {
    /// Flattens an array of lazy void futures into a single void future.
    /// - note: each subsequent future will wait for the previous to complete before starting.
    public func syncFlatten(on worker: Worker) -> Future<Void> {
        let flatten: Future<[Void]> = self.syncFlatten(on: worker)
        return flatten.transform(to: ())
    }
}

extension Collection where Element: FutureType {
    /// Flattens an array of futures into a future with an array of results.
    /// - note: the order of the results will match the order of the futures in the input array.
    public func flatten(on worker: Worker) -> Future<[Element.Expectation]> {
        let eventLoop = worker.eventLoop
        
        // Avoid unnecessary work
        guard count > 0 else {
            return eventLoop.newSucceededFuture(result: [])
        }
        
        var promises = [EventLoopPromise<Element.Expectation>]()
        for future in self {
            let promise = eventLoop.newPromise(of: Element.Expectation.self)
            promises.append(promise)
            future.addAwaiter { result in
                switch result {
                case .success(let value):
                    promise.succeed(result: value)
                case .error(let error):
                    promise.fail(error: error)
                }
            }
        }
        let futures = promises.map { $0.futureResult }
        return Future<[Element.Expectation]>.reduce(
            into: [],
            futures,
            eventLoop: eventLoop
        ) { partialResult, nextElement in
            return partialResult.append(nextElement)
        }
    }
}

extension Collection where Element == Future<Void> {
    /// Flattens an array of void futures into a single one.
    public func flatten(on worker: Worker) -> Future<Void> {
        let flatten: Future<[Void]> = self.flatten(on: worker)
        return flatten.map(to: Void.self) { _ in return }
    }
}
