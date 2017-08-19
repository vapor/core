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
            
            promise.onComplete(asynchronously: nil) { result in
                heap.append(result)
            }
            
            promise = newPromise
        }
        
        promise.onComplete(asynchronously: nil) { result in
            heap.append(result)
            handler(heap)
        }
    }
}
