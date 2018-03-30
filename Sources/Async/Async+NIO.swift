import Dispatch
import NIO

/// Convenience shorthand for `EventLoopFuture`.
public typealias Future = EventLoopFuture

/// Convenience shorthand for `EventLoopPromise`.
public typealias Promise = EventLoopPromise

extension EventLoop {
    /// Creates a new promise for the specified type.
    public func newPromise<T>(_ type: T.Type, file: StaticString = #file, line: UInt = #line) -> Promise<T> {
        return newPromise(file: file, line: line)
    }
}
