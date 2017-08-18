import Foundation
import Dispatch


public final class Future<Expectation> : FutureBase<Expectation> {
    /// Creates a new future, combining `futures` into a single future that completes once all contained futures complete
    public convenience init<FT, S>(_ futures: S) where S : Sequence, S.Element == FT, FT : FutureType, FT.Expectation == Void, Expectation == Void {
        self.init {
            _ = try futures.await(until: DispatchTime.distantFuture)
        }
    }
    
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
    
    public override init<Base, FT : FutureType, OFT : FutureType>(transform: @escaping ((Base) throws -> (OFT)), from: FT) where FT.Expectation == Base, OFT.Expectation == Expectation {
        super.init(transform: transform, from: from)
    }
    
    public override init<Base, FT : FutureType>(transform: @escaping ((Base) throws -> (Expectation)), from: FT) where FT.Expectation == Base {
        super.init(transform: transform, from: from)
    }
}
