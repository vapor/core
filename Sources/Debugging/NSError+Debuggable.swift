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
    
    public var possibleCauses: [String] {
        if let reason =  self.localizedFailureReason {
            return [reason]
        }
        return []
    }
    
    public var suggestedFixes: [String] {
        if let suggestion = self.localizedRecoverySuggestion {
            return [suggestion]
        }
        return []
    }
}
