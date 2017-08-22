import Foundation
import Dispatch

/// A future is an entity that stands inbetween the provider and receiver.
///
/// A provider returns a future type that will be completed with the future result
///
/// A future can also contain an error, rather than a result.
public final class Future<Expected> : FutureType {
    public typealias Expectation = Expected
    
    var error: Error?
    var expectation: Expectation?
    
    let lock = NSRecursiveLock()
    
    public typealias Result = FutureResult<Expectation>
    typealias Handler = ((FutureResult<Expectation>) -> ())
    
    /// A list of all handlers waiting to 
    var awaiters = [(handler: Handler, dispatch: DispatchQueue?)]()
    
    /// `true` if the future is already completed.
    public var isCompleted: Bool {
        lock.lock()
        defer { lock.unlock() }
        
        return self.expectation != nil || self.error != nil
    }
    
    internal func complete() {
        lock.lock()
        defer { lock.unlock() }
        
        let result: FutureResult<Expectation>
        
        if let error = error {
            result = .error(error)
        } else if let expectation = expectation {
            result = .expectation(expectation)
        } else {
            return
        }
        
        for (waiter, dispatchQueue) in awaiters {
            guard let dispatchQueue = dispatchQueue else {
                continue
            }
            
            dispatchQueue.async {
                waiter(result)
            }
        }
        
        for (waiter, dispatchQueue) in awaiters where dispatchQueue == nil {
            waiter(result)
        }
    }
    
    /// Adds a handler to be asynchronously executed on completion of this future.
    ///
    /// This handler will be executed regardless of the result.
    ///
    ///
    public func onComplete(asynchronously: DispatchQueue? = nil, _ handler: @escaping ((FutureResult<Expectation>) -> ())) {
        await(dispatch: asynchronously, handler)
    }
    
    /// Internal helper for registering a handler
    ///
    /// Also calls the handler if a result is already stored
    internal func await(dispatch: DispatchQueue? = nil, _ handler: @escaping ((FutureResult<Expectation>) -> ())) {
        lock.lock()
        defer { lock.unlock() }
        
        if let expectation = expectation {
            handler(.expectation(expectation))
        } else if let error = error {
            handler(.error(error))
        } else {
            self.awaiters.append((handler: handler, dispatch: dispatch))
        }
    }
    
    /// Adds a handler to be asynchronously executed on completion of this future.
    ///
    /// Will *only* be executed if an error occurred that matches the provided type. Successful results will not call this handler. Any other errors will also not call this handler.
    ///
    /// - parameter asynchronously: Spawns the closure using the result asynchronously, thus preventing influence by other registered handlers
    /// - parameter type: The error type to require for handling
    /// - parameter handler: The handler to execute when the specified error occurred in this future
    public func `catch`<E: Error>(asynchronously: DispatchQueue? = nil, _ type: E.Type, _ handler: @escaping ((E) -> ())) {
        await(dispatch: asynchronously) { result in
            guard case .error(let anyError) = result, let error = anyError as? E else {
                return
            }
            
            handler(error)
        }
    }
    
    /// Adds a handler to be asynchronously executed on completion of this future.
    ///
    /// Will *only* be executed if an error occurred. Successful results will not call this handler.
    ///
    /// - parameter asynchronously: Spawns the closure using the result asynchronously, thus preventing influence by other registered handlers
    /// - parameter handler: The handler to execute when an error occurred in this future
    public func `catch`(asynchronously: DispatchQueue? = nil, _ handler: @escaping ((Error) -> ())) {
        await(dispatch: asynchronously) { result in
            guard case .error(let error) = result else {
                return
            }
            
            handler(error)
        }
    }
    
    /// Adds a handler to be asynchronously executed on completion of this future.
    ///
    /// Will *not* be executed if an error occurred
    ///
    /// - parameter asynchronously: Spawns the closure using the result asynchronously, thus preventing influence by other registered handlers
    /// - parameter handler: Handles the expected outcome.
    public func then(asynchronously: DispatchQueue? = nil, _ handler: @escaping ((Expectation) -> ())) {
        await(dispatch: asynchronously) { result in
            guard case .expectation(let expectation) = result else {
                return
            }
            
            handler(expectation)
        }
    }
    
    /// Waits until the specified time for a result.
    ///
    /// Will return the results when available unless the specified time has been reached, in which case it will timeout
    public func await(until time: DispatchTime = .distantFuture) throws -> Expectation {
        let semaphore = DispatchSemaphore(value: 0)
        var awaitedResult: FutureResult<Expectation>?
        
        self.onComplete { result in
            awaitedResult = result
            semaphore.signal()
        }
        
        guard semaphore.wait(timeout: time) == .success else {
            throw FutureTimeout()
        }
        
        if let awaitedResult = awaitedResult {
            return try awaitedResult.assertSuccess()
        }
        
        // this can *never* happen
        throw FutureTimeout()
    }
    
    /// Waits for the specified duration for a result.
    ///
    /// Will return the results when available unless the specified timeout has been reached, in which case it will timeout
    public func await(for interval: DispatchTimeInterval) throws -> Expectation {
        return try self.await(until: DispatchTime.now() + interval)
    }
    
    /// Creates a new, uncompleted, unprovoked future
    internal init() {}
    
    /// Creates a future, executing asynchronously on either the provided or global queue
    ///
    /// - parameter queue: If provided, will execute the closure on this queue
    /// - parameter closure: The closure to execute.
    public init(queue: DispatchQueue? = nil, _ closure: @escaping (() throws -> (Expectation))) {
        let queue = queue ?? DispatchQueue.global()
        
        queue.async {
            do {
                self.expectation = try closure()
            } catch {
                self.error = error
            }
            
            self.complete()
        }
    }
    
    /// Creates a new future by transforming one future into a new future.
    ///
    /// The post-transform future will become this future
    internal init<Base>(transform: @escaping ((Base) throws -> (Future<Expectation>)), from: Future<Base>) {
        from.onComplete(asynchronously: nil) { result in
            switch result {
            case .expectation(let data):
                do {
                    let promise = try transform(data)
                    
                    promise.onComplete(asynchronously: nil) { result in
                        switch result {
                        case .expectation(let expectation):
                            self.expectation = expectation
                        case .error(let error):
                            self.error = error
                        }
                        
                        self.complete()
                    }
                } catch {
                    self.error = error
                    self.complete()
                }
            case .error(let error):
                self.error = error
                self.complete()
            }
        }
    }
    
    /// Creates a new future by transforming one future's results into another result.
    ///
    /// The post-transform result will be this future's result.
    internal init<Base>(transform: @escaping ((Base) throws -> (Expectation)), from: Future<Base>) {
        from.onComplete(asynchronously: nil) { result in
            switch result {
            case .expectation(let data):
                do {
                    self.expectation = try transform(data)
                } catch {
                    self.error = error
                }
            case .error(let error):
                self.error = error
            }
            
            self.complete()
        }
    }
    
    public func map<B>(_ closure: @escaping ((Expectation) throws -> (B))) -> Future<B> {
        return Future<B>(transform: closure, from: self)
    }
    
    public func replace<B>(_ closure: @escaping ((Expectation) throws -> (Future<B>))) -> Future<B> {
        return Future<B>(transform: closure, from: self)
    }
}

public struct FutureTimeout : Error {}
