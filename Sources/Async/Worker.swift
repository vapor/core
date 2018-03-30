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
