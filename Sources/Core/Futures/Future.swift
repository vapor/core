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
    private let queue: DispatchQueue

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
        self.queue = DispatchQueue(label: "codes.vapor.core.future.lock")
    }
    
    /// `true` if the future is already completed.
    public var isCompleted: Future<Bool> {
        let promise = Promise(Bool.self)

        queue.async {
            promise.complete(self.result != nil)
        }
        
        return promise.future
    }

    // Completes the result, notifying awaiters.
    internal func complete(with result: Result) {
        queue.async {
            guard self.result == nil else {
                return
            }
            self.result = result

            self.awaiters.forEach { awaiter in
                if let queue = awaiter.queue {
                    queue.async {
                        awaiter.callback(result)
                    }
                } else {
                    awaiter.callback(result)
                }
            }
        }
    }

    /// Locked method for adding an awaiter
    public func completeOrAwait(on queue: DispatchQueue?, callback: @escaping ResultCallback) {
        self.queue.async {
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
                self.awaiters.append(awaiter)
            }
        }
    }
}
