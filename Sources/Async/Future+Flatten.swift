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
        
        let resultPromise: EventLoopPromise<[Element.Expectation]> = eventLoop.newPromise()
        var promiseFulfilled = false
        
        let expectedCount = self.count
        var fulfilledCount = 0
        var results = Array<Element.Expectation?>(repeating: nil, count: expectedCount)
        for (index, future) in self.enumerated() {
            future.addAwaiter { result in
                let work: () -> Void = {
                    guard !promiseFulfilled else { return }
                    switch result {
                    case .success(let result):
                        results[index] = result
                        fulfilledCount += 1
                        
                        if fulfilledCount == expectedCount {
                            promiseFulfilled = true
                            // Forcibly unwrapping is okay here, because we know that each result has been filled.
                            resultPromise.succeed(result: results.map { $0! })
                        }
                    case .error(let error):
                        promiseFulfilled = true
                        resultPromise.fail(error: error)
                    }
                }
                
                if future.eventLoop === eventLoop {
                    work()
                } else {
                    eventLoop.execute(work)
                }
            }
        }
        return resultPromise.futureResult
    }
}

extension Collection where Element == Future<Void> {
    /// Flattens an array of void futures into a single one.
    public func flatten(on worker: Worker) -> Future<Void> {
        let flatten: Future<[Void]> = self.flatten(on: worker)
        return flatten.map(to: Void.self) { _ in return }
    }
}
