import NIO



public typealias Future = EventLoopFuture
public typealias Promise = EventLoopPromise

extension EventLoop {
    /// Creates a new promise for the specified type.
    public func newPromise<T>(_ type: T.Type) -> Promise<T> {
        return newPromise()
    }
}

/// Has an EventLoop.
public protocol Worker {
    /// This worker's event loop. All async work done
    /// on this worker _must_ occur on its event loop.
    var eventLoop: EventLoop { get }
}

extension EventLoopFuture: FutureType {
    public typealias Expectation = T

    public func addAwaiter(callback: @escaping (FutureResult<T>) -> ()) {
        self.do { result in
            callback(.success(result))
        }.catch { error in
            callback(.error(error))
        }
    }
}

extension Promise {
    @available(*, deprecated, renamed: "succeed(result:)")
    public func complete(_ result: T) {
        self.succeed(result: result)
    }

    @available(*, deprecated, renamed: "fail(error:)")
    public func fail(_ error: Error) {
        self.fail(error: error)
    }

    @available(*, deprecated, renamed: "futureResult")
    public var future: Future<T> {
        return futureResult
    }
}

extension Promise where T == Void {
    public func succeed() {
        self.succeed(result: ())
    }
    @available(*, deprecated, renamed: "succeed()")
    public func complete() {
        self.succeed()
    }
}

extension Future where T == Void {
    public static func done(on worker: Worker) -> Future<T> {
        let promise = worker.eventLoop.newPromise(Void.self)
        promise.succeed()
        return promise.futureResult
    }
}

struct _EventLoopWorker: Worker {
    let eventLoop: EventLoop
    init(_ eventLoop: EventLoop) {
        self.eventLoop = eventLoop
    }
}

public func wrap(_ eventLoop: EventLoop) -> Worker {
    return _EventLoopWorker(eventLoop)
}
