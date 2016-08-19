#if os(Linux)
public func background(_ function: @escaping () -> Void) throws {
    let _ = try Strand(function)
}
#else
import Foundation

let background = DispatchQueue.global()

public func background(function: @escaping () -> Void) throws {
    background.async(execute: function)
}
#endif
