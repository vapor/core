public final class Promise<Expectation> {
    public init() { }
    
    public let future = Future<Expectation>()
    
    public func complete(_ error: Error) throws {
        guard !future.isCompleted else {
            throw FutureAlreadyCompleted()
        }
        
        future.error = error
        future.complete()
    }
    
    public func complete(_ expectation: Expectation) throws {
        guard !future.isCompleted else {
            throw FutureAlreadyCompleted()
        }
        
        future.expectation = expectation
        future.complete()
    }
    
    public func complete(_ closure: () throws -> (Expectation)) throws {
        guard !future.isCompleted else {
            throw FutureAlreadyCompleted()
        }
        
        do {
            future.expectation = try closure()
        } catch {
            future.error = error
        }
        
        future.complete()
    }
}

public struct FutureAlreadyCompleted : Error {}
