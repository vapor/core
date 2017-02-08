import Dispatch

let background = DispatchQueue.global()

public func background(function: @escaping () -> Void) {
    background.async(execute: function)
}
