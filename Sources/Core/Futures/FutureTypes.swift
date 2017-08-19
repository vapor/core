import Foundation
import Dispatch

extension FutureType {
    public typealias ResultHandler = ((FutureResult<Expectation>) -> ())
}

public protocol FutureType {
    associatedtype Expectation
    
    func onComplete(asynchronously: DispatchQueue?, _ handler: @escaping ResultHandler)
    func await(until time: DispatchTime) throws -> Expectation
}
