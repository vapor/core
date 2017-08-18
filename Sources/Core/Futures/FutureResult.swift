import Foundation
import Dispatch

// Indirect so futures can be nested
public indirect enum FutureResult<Expectation> : FutureResultType {
    case error(Error)
    case expectation(Expectation)
    
    public func assertSuccess() throws -> Expectation {
        switch self {
        case .expectation(let data):
            return data
        case .error(let error):
            throw error
        }
    }
}
