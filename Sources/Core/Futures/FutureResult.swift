import Foundation
import Dispatch

// Indirect so futures can be nested
public indirect enum FutureResult<Expectation> {
    case error(Error)
    case expectation(Expectation)
    
    /// Throws an error if this contains an error, returns the Expectation otherwise
    public func assertSuccess() throws -> Expectation {
        switch self {
        case .expectation(let data):
            return data
        case .error(let error):
            throw error
        }
    }
}
