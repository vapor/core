public final class Promise<Expectation> {
    public init() { }
    
    public let future = Future<Expectation>()
    
    public func complete(_ error: Error) {
        guard !future.isCompleted else {
            return
        }
        
        future.error = error
        future.complete()
    }
    
    public func complete(_ expectation: Expectation) {
        guard !future.isCompleted else {
            return
        }
        
        future.expectation = expectation
        future.complete()
    }
    
    public func complete(_ closure: () throws -> (Expectation)) {
        guard !future.isCompleted else {
            return
        }
        
        do {
            future.expectation = try closure()
        } catch {
            future.error = error
        }
        
        future.complete()
    }
}
