import Foundation

extension NSError: Debuggable {
    
    /// See `Debuggable`
    public var identifier: String {
        return "\(self.debugDescription)_\(Int.random(in: 0...1000))"
    }
    
    /// See `Debuggable`
    public var reason: String {
        return self.debugDescription
    }
}
