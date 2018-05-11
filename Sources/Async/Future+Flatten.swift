// MARK: Flatten

/// A closure that returns a future.
public typealias LazyFuture<T> = () throws -> Future<T>

extension Collection where Element == LazyFuture<Void> {
    /// Flattens an array of lazy futures into a future with an array of results.
    /// - note: each subsequent future will wait for the previous to complete before starting.
    public func syncFlatten(on worker: Worker) -> Future<Void> {
        let promise = worker.eventLoop.newPromise(Void.self)

        var iterator = makeIterator()
        func handle(_ future: LazyFuture<Void>) {
            do {
                try future().do { res in
                    if let next = iterator.next() {
                        handle(next)
                    } else {
                        promise.succeed()
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
            promise.succeed()
        }

        return promise.futureResult
    }
}

extension Collection where Element: FutureType {
    /// Flattens an array of futures into a future with an array of results.
    /// - note: the order of the results will match the order of the futures in the input array.
    public func flatten(on worker: Worker) -> Future<[Element.Expectation]> {
        // algorithm won't work unless there is at least one element
        guard count > 0 else {
            // just return an empty array
            return worker.eventLoop.newSucceededFuture(result: [])
        }

        // create promise and array of elements with reservation
        let promise = worker.eventLoop.newPromise([Element.Expectation].self)

        // allocate results array
        var results: [Element.Expectation?] = .init(repeating: nil, count: count)
        // keep track of remaining results
        var remaining = count

        // await each element, placing in same index when done
        for (i, el) in enumerated() {
            el.addAwaiter { res in
                remaining -= 1
                switch res {
                case .error(let e):
                    // one of the elements failed, the whole flatten must fail
                    promise.fail(error: e)
                case .success(let el):
                    // insert the element into its array index
                    results[i] = el
                    // zero remaining, succeed the promise
                    if remaining == 0 {
                        promise.succeed(result: results.compactMap { $0 })
                    }
                }
            }
        }

        // return future result
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
