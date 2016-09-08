import Dispatch

let background = DispatchQueue.global()

public func background(function: @escaping () -> Void) throws {
    background.async(execute: function)
}
