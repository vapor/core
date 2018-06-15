import Dispatch

/// `Worker`s are types that have a reference to an `EventLoop`.
///
/// You will commonly see `Worker`s required after an `on:` label.
///
///     return Future.map(on: req) { ... }
///
/// The most common containers you will interact with in Vapor are:
/// - `Application`
/// - `Request`
/// - `Response`
///
/// You can also use a SwiftNIO `EventGroup` directly as your `Worker`.
///
///     let worker = MultiThreadedEventLoopGroup(numThreads: 2)
///     ...
///     let connection = database.makeConnection(on: worker)
///
public typealias Worker = EventLoopGroup

/// `Worker`s are types that have a reference to an `EventLoop`.
///
/// You will commonly see `Worker`s required after an `on:` label.
///
///     return Future.map(on: req) { ... }
///
/// The most common containers you will interact with in Vapor are:
/// - `Application`
/// - `Request`
/// - `Response`
///
/// You can also use a SwiftNIO `EventGroup` directly as your `Worker`.
///
///     let worker = MultiThreadedEventLoopGroup(numThreads: 2)
///     ...
///     let connection = database.makeConnection(on: worker)
///
extension Worker {
    /// See `BasicWorker`.
    public var eventLoop: EventLoop {
        return next()
    }
    
    /// Creates a new, succeeded `Future` from the worker's event loop with a `Void` value.
    ///
    ///    let a: Future<Void> = req.future()
    ///
    /// - returns: The succeeded future.
    public func future() -> Future<Void> {
        return self.eventLoop.newSucceededFuture(result: ())
    }
    
    /// Creates a new, succeeded `Future` from the worker's event loop.
    ///
    ///    let a: Future<String> = req.future("hello")
    ///
    /// - parameters:
    ///     - value: The value that the future will wrap.
    /// - returns: The succeeded future.
    public func future<T>(_ value: T) -> Future<T> {
        return self.eventLoop.newSucceededFuture(result: value)
    }
    
    /// Creates a new, failed `Future` from the worker's event loop.
    ///
    ///    let b: Future<String> = req.future(error: Abort(...))
    ///
    /// - parameters:
    ///    - error: The error that the future will wrap.
    /// - returns: The failed future.
    public func future<T>(error: Error) -> Future<T> {
        return self.eventLoop.newFailedFuture(error: error)
    }
}

/// A basic `Worker` type that has a single `EventLoop`.
public protocol BasicWorker: Worker {
    /// This worker's event loop. All async work done on this worker _must_ occur on its `EventLoop`.
    var eventLoop: EventLoop { get }
}

extension BasicWorker {
    /// See `EventLoopGroup`.
    public func next() -> EventLoop {
        return self.eventLoop
    }

    /// See `EventLoopGroup`.
    public func shutdownGracefully(queue: DispatchQueue, _ callback: @escaping (Error?) -> Void) {
        eventLoop.shutdownGracefully(queue: queue, callback)
    }
}
