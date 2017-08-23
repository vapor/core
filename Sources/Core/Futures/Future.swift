import Foundation
import Dispatch

/// A future is an entity that stands inbetween the provider and receiver.
///
/// A provider returns a future type that will be completed with the future result
///
/// A future can also contain an error, rather than a result.
public final class Future<T>: FutureType {
    /// Future expectation type
    public typealias Expectation = T

    /// The future's result will be stored
    /// here when it is resolved.
    private var result: Result?

    /// The future's internal lock
    private let lock = NSRecursiveLock()

    /// Contains information about callbacks
    /// waiting for this future to complete
    private struct Awaiter {
        let callback: ResultCallback
        let queue: DispatchQueue?
    }

    /// A list of all handlers waiting to 
    private var awaiters: [Awaiter]

    /// Creates a new, uncompleted, unprovoked future
    /// Can only be created by a Promise, so this is hidden
    internal init() {
        awaiters = []
        result = nil
    }
    
    /// `true` if the future is already completed.
    public var isCompleted: Bool {
        lock.lock()
        defer { lock.unlock() }
        
        return result != nil
    }

    // Completes the result, notifying awaiters.
    internal func complete(with result: Result) {
        lock.lock()
        defer { lock.unlock() }

        guard self.result == nil else {
            return
        }
        self.result = result

        awaiters.forEach { awaiter in
            if let queue = awaiter.queue {
                queue.async {
                    awaiter.callback(result)
                }
            } else {
                awaiter.callback(result)
            }
        }
    }

    /// Locked method for adding an awaiter
    public func completeOrAwait(on queue: DispatchQueue?, callback: @escaping ResultCallback) {
        lock.lock()
        defer { lock.unlock() }

        if let result = self.result {
            if let queue = queue {
                queue.async {
                    callback(result)
                }
            } else {
                callback(result)
            }
        } else {
            let awaiter = Awaiter(callback: callback, queue: queue)
            awaiters.append(awaiter)
        }
    }
}
