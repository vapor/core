#if os(Linux)
import Dispatch
#endif
import Foundation

let background = DispatchQueue.global()

public func background(function: @escaping () -> Void) throws {
    background.async(execute: function)
}

