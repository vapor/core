import Foundation
import Dispatch

public class FutureBase<Expectation> : FutureType {
    var error: Error?
    var expectation: Expectation?
    
    let lock = NSRecursiveLock()
    
    public typealias Result = FutureResult<Expectation>
    typealias Handler = ((FutureResult<Expectation>) -> ())
    
    var awaiters = [(handler: Handler, dispatch: Bool)]()
    
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
        
        for (waiter, dispatchAsync) in awaiters where dispatchAsync {
            DispatchQueue.global().async {
                waiter(result)
            }
        }
        
        for (waiter, dispatchAsync) in awaiters where !dispatchAsync {
            waiter(result)
        }
    }
    
    public func onComplete(_ handler: @escaping ((FutureResult<Expectation>) -> ())) {
        await(handler)
    }
    
    internal func await(dispatch: Bool = false, _ handler: @escaping ((FutureResult<Expectation>) -> ())) {
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
    
    public func `catch`<E: Error>(_ type: E, _ handler: @escaping ((E) -> ())) {
        await { result in
            guard case .error(let anyError) = result, let error = anyError as? E else {
                return
            }
            
            handler(error)
        }
    }
    
    public func `catch`(_ handler: @escaping ((Error) -> ())) {
        await { result in
            guard case .error(let error) = result else {
                return
            }
            
            handler(error)
        }
    }
    
    public var isCompleted: Bool {
        lock.lock()
        defer { lock.unlock() }
        
        return self.expectation != nil || self.error != nil
    }
    
    public func then(_ handler: @escaping ((Expectation) -> ())) {
        await { result in
            guard case .expectation(let expectation) = result else {
                return
            }
            
            handler(expectation)
        }
    }
    
    public func await(until time: DispatchTime) throws -> Expectation {
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
        
        throw FutureTimeout()
    }
    
    public func await(for interval: DispatchTimeInterval) throws -> Expectation {
        return try self.await(until: DispatchTime.now() + interval)
    }
    
    // reduce
    internal init<Base, FT : FutureType, OFT : FutureType>(transform: @escaping ((Base) throws -> (OFT)), from: FT) where FT.Expectation == Base, OFT.Expectation == Expectation {
        from.onComplete { result in
            switch result {
            case .expectation(let data):
                do {
                    let promise = try transform(data)
                    
                    promise.onComplete { result in
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
    
    internal init() {}
    
    // map
    internal init<Base, FT : FutureType>(transform: @escaping ((Base) throws -> (Expectation)), from: FT) where FT.Expectation == Base {
        from.onComplete { result in
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
}
