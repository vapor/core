import Foundation
import Dispatch

/// A future is an entity that stands inbetween the provider and receiver.
///
/// A provider returns a future type that will be completed with the future result
///
/// A future can also contain an error, rather than a result.
public final class Future<Expectation> : FutureBase<Expectation> {
    /// Creates a new future, combining multiple `future` instances of the same type into a single future that completes once all contained futures complete
    public convenience init<FT, S>(_ futures: S) where S : Sequence, S.Element == FT, FT : FutureType, FT.Expectation == Void, Expectation == Void {
        self.init {
            _ = try futures.await(until: DispatchTime.distantFuture)
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
    internal override init<Base, FT : FutureType, OFT : FutureType>(transform: @escaping ((Base) throws -> (OFT)), from: FT) where FT.Expectation == Base, OFT.Expectation == Expectation {
        super.init(transform: transform, from: from)
    }
    
    /// Creates a new future by transforming one future's results into another result.
    ///
    /// The post-transform result will be this future's result.
    internal override init<Base, FT : FutureType>(transform: @escaping ((Base) throws -> (Expectation)), from: FT) where FT.Expectation == Base {
        super.init(transform: transform, from: from)
    }
}
