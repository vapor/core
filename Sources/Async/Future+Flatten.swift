// MARK: Flatten

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
        // create an iterator
        var iterator = makeIterator()
        // get first element or return empty success
        guard let first = iterator.next() else {
            return worker.eventLoop.newSucceededFuture(result: [])
        }

        // create promise and array of elements with reservation
        let promise = worker.eventLoop.newPromise([Element.Expectation].self)
        var elements: [Element.Expectation] = []
        elements.reserveCapacity(self.count)

        // sub method for handling each future element.
        // called recursively starting with the first element.
        func handle(_ future: Element) {
            future.addAwaiter { res in
                switch res {
                case .error(let e): promise.fail(error: e)
                case .success(let el):
                    elements.append(el)
                    if let next = iterator.next() {
                        handle(next)
                    } else {
                        promise.succeed(result: elements)
                    }
                }
            }
        }

        // start handling the first element
        handle(first)
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
