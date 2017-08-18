import Foundation
import Dispatch

public final class ManualFuture<Expectation> : FutureBase<Expectation> {
    public override init() {
        super.init()
    }
    
    public func complete(_ expectation: Expectation) {
        self.expectation = expectation
        self.complete()
    }
    
    public func complete(_ error: Error) {
        self.error = error
        self.complete()
    }
}
