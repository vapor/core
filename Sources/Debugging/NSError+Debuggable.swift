import Foundation

extension NSError: Debuggable {
    
    /// See `Debuggable`
    public var identifier: String {
        return "\(self.code)"
    }
    
    /// See `Debuggable`
    public var reason: String {
        return self.debugDescription
    }
}
