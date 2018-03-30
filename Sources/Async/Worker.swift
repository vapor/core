import Dispatch

/// Convenience shorthand for `EventLoopGroup`.
public typealias Worker = EventLoopGroup

/// Has an `EventLoop`.
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
