import Foundation
import Dispatch

/// A future is an entity that stands inbetween the provider and receiver.
///
/// A provider returns a future type that will be completed with the future result
///
/// A future can also contain an error, rather than a result.
public final class Future<Expectation> : FutureBase<Expectation> {
    /// Creates a new future, combining multiple `future` instances of the same type into a single future that completes once all contained futures complete
    public init<FT, S>(_ futures: S) where S : Sequence, S.Element == FT, FT : FutureType, FT.Expectation == Void, Expectation == Void {
        super.init()
        
        futures.onBulkComplete { _ in
            self.expectation = ()
            complete()
        }
    }
    
    /// Creates a future, executing asynchronously on either the provided or global queue
    ///
    /// - parameter queue: If provided, will execute the closure on this queue
    /// - parameter closure: The closure to execute.
    public init(queue: DispatchQueue? = nil, _ closure: @escaping (() throws -> (Expectation))) {
        super.init()
        
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
    internal init<Base, FT : FutureType, OFT : FutureType>(transform: @escaping ((Base) throws -> (OFT)), from: FT) where FT.Expectation == Base, OFT.Expectation == Expectation {
        super.init()
        
        from.onComplete(asynchronously: false) { result in
            switch result {
            case .expectation(let data):
                do {
                    let promise = try transform(data)
                    
                    promise.onComplete(asynchronously: false) { result in
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
    internal init<Base, FT : FutureType>(transform: @escaping ((Base) throws -> (Expectation)), from: FT) where FT.Expectation == Base {
        super.init()
        
        from.onComplete(asynchronously: false) { result in
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
