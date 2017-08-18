import Foundation
import Dispatch

public protocol FutureResultType {
    associatedtype Expectation
    
    func assertSuccess() throws -> Expectation
}

extension FutureType {
    public typealias ResultHandler = ((FutureResult<Expectation>) -> ())
}

public protocol FutureType {
    associatedtype Expectation
    
    func onComplete(asynchronously: Bool, _ handler: @escaping ResultHandler)
    func await(until time: DispatchTime) throws -> Expectation
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
