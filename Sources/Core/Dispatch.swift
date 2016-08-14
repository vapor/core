#if os(Linux)
import Strand

public func background(_ function: () -> Void) throws {
    let _ = try Strand(function)
}
#else
import Foundation

let background = DispatchQueue.global()

public func background(function: () -> Void) throws {
    background.async(execute: function)
}
#endif
