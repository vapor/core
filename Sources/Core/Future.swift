import Foundation
import Dispatch

extension Sequence where Element : FutureType {
    public typealias Expectation = Element.Expectation
    public typealias Result = FutureResult<Expectation>
    
    public func await(for interval: DispatchTimeInterval) throws -> [Expectation] {
        let time = DispatchTime.now() + interval
        
        return try self.await(until: time)
    }
    
    public func await(until time: DispatchTime) throws -> [Expectation] {
        return try self.map {
            try $0.await(until: time)
        }
    }
    
    public func onBulkComplete(_ handler: @escaping ((([Result]) -> ()))) {
        var all = Array(self)
        var heap = [Result]()
        
        guard all.count > 0 else {
            handler([])
            return
        }
        
        var promise = all.removeFirst()
        
        while all.count > 0 {
            let newPromise = all.removeFirst()
            
            promise.onComplete { result in
                heap.append(result)
            }
            
            promise = newPromise
        }
        
        promise.onComplete { result in
            heap.append(result)
            handler(heap)
        }
    }
}

public protocol FutureResultType {
    associatedtype Expectation
    
    func assertSuccess() throws -> Expectation
}

extension FutureType {
    public typealias ResultHandler = ((FutureResult<Expectation>) -> ())
}

public protocol FutureType {
    associatedtype Expectation
    
    func onComplete(_ handler: @escaping ResultHandler)
    func await(until time: DispatchTime) throws -> Expectation
}

// Indirect so futures can be nested
public indirect enum FutureResult<Expectation> : FutureResultType {
    case error(Error)
    case expectation(Expectation)
    
    public func assertSuccess() throws -> Expectation {
        switch self {
        case .expectation(let data):
            return data
        case .error(let error):
            throw error
        }
    }
}

public final class Future<Expectation> : FutureType {
    var error: Error?
    var expectation: Expectation?
    
    let lock = NSRecursiveLock()
    
    public typealias Result = FutureResult<Expectation>
    typealias Handler = ((FutureResult<Expectation>) -> ())
    
    var awaiters = [(handler: Handler, dispatch: Bool)]()
    
    fileprivate func complete() {
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
    
    fileprivate func await(dispatch: Bool = false, _ handler: @escaping ((FutureResult<Expectation>) -> ())) {
        self.awaiters.append((handler: handler, dispatch: dispatch))
    }
    
    public func onComplete(_ handler: @escaping ((FutureResult<Expectation>) -> ())) {
        await(handler)
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
    internal init<Base, FT : FutureType>(transform: @escaping ((Base) throws -> (Future<Expectation>)), from: FT) where FT.Expectation == Base {
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
    
    /// Creates a new future, combining `futures` into a single future that completes once all contained futures complete
    public convenience init<FT, S>(_ futures: S) where S : Sequence, S.Element == FT, FT : FutureType, FT.Expectation == Void, Expectation == Void {
        self.init {
            _ = try futures.await(until: DispatchTime.distantFuture)
        }
    }
    
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
}

public struct FutureTimeout : Error {}

extension FutureType {
    public func map<B>(_ closure: @escaping ((Expectation) throws -> (B))) -> Future<B> {
        return Future<B>(transform: closure, from: self)
    }
    
    public func replace<B>(_ closure: @escaping ((Expectation) throws -> (Future<B>))) -> Future<B> {
        return Future<B>(transform: closure, from: self)
    }
}
