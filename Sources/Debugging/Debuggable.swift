import Foundation

/// `Debuggable` provides an interface that allows a type
/// to be more easily debugged in the case of an error.
public protocol Debuggable: CustomDebugStringConvertible, CustomStringConvertible, Identifiable, LocalizedError {
    /// The reason for the error.
    /// Typical implementations will switch over `self`
    /// and return a friendly `String` describing the error.
    /// - note: It is most convenient that `self` be a `Swift.Error`.
    ///
    /// Here is one way to do this:
    ///
    ///     switch self {
    ///     case someError:
    ///        return "A `String` describing what went wrong including the actual error: `Error.someError`."
    ///     // other cases
    ///     }
    var reason: String { get }
}

// MARK: Defaults

extension Debuggable {
    public var debugDescription: String {
        return debuggableHelp(format: .long)
    }

    public var description: String {
        return debuggableHelp(format: .short)
    }
}

extension Debuggable {
    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encode(self.reason)
    }
}

// MARK: Localized

extension Debuggable {
    /// A localized message describing what error occurred.
    public var errorDescription: String? { return description }

    /// A localized message describing the reason for the failure.
    public var failureReason: String? { return reason }

    /// A localized message describing how one might recover from the failure.
    public var recoverySuggestion: String? { return (self as? Helpable)?.suggestedFixes.first }

    /// A localized message providing "help" text if the user requests help.
    public var helpAnchor: String? { return (self as? Helpable)?.documentationLinks.first }
}


// MARK: Representations

extension Debuggable {
    /// A computed property returning a `String` that encapsulates
    /// why the error occurred, suggestions on how to fix the problem,
    /// and resources to consult in debugging (if these are available).
    /// - note: This representation is best used with functions like print()
    public func debuggableHelp(format: HelpFormat) -> String {
        var print: [String] = []

        switch format {
        case .long:
            print.append("⚠️ \(Self.readableName): \(reason)\n- id: \(fullIdentifier)")
        case .short:
            print.append("⚠️ [\(fullIdentifier): \(reason)]")
        }

        if let traceable = self as? Traceable {
            print.append(traceable.traceableHelp(format: format))
        }

        if let helpable = self as? Helpable {
            print.append(helpable.helpableHelp(format: format))
        }

        if let traceable = self as? Traceable, format == .long {
            let lines = ["Stack Trace:"] + traceable.stackTrace
            print.append(lines.joined(separator: "\n"))
        }


        switch format {
        case .long:
            return print.joined(separator: "\n\n")
        case .short:
            return print.joined(separator: " ")
        }
    }
}
