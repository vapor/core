import Foundation
import Dispatch

/// A future is an entity that stands inbetween the provider and receiver.
///
/// A provider returns a future type that will be completed with the future result
///
/// A future can also contain an error, rather than a result.
///
/// This future can be manually completed, which is useful for frameworks/libraries that are built asynchronously
public final class ManualFuture<Expectation> : FutureBase<Expectation> {
    /// Creates a new, uncompleted future
    public override init() {
        super.init()
    }
    
    /// Completes the future successfully
    ///
    /// - throws: If the future is already completed
    public func complete(_ expectation: Expectation) throws {
        guard !isCompleted else {
            throw FutureAlreadyCompleted()
        }
        
        self.expectation = expectation
        self.complete()
    }
    
    /// Completes the future successfully
    ///
    /// - throws: If the future is already completed
    public func complete(_ error: Error) throws {
        guard !isCompleted else {
            throw FutureAlreadyCompleted()
        }
        
        self.error = error
        self.complete()
    }
}

public struct FutureAlreadyCompleted : Error {}
