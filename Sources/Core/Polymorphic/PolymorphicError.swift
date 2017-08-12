import Debugging

/// Errors that can be thrown from Polymorphic methods.
public struct PolymorphicError: Error, Debuggable, Traceable {
    fileprivate let kind: Kind
    public let reason: String
    public let file: String
    public let function: String
    public let line: UInt
    public let column: UInt
    public let stackTrace: [String]


    public var identifier: String {
        return kind.rawValue
    }

    fileprivate init(kind: Kind, reason: String, file: String, function: String, line: UInt, column: UInt) {
        self.kind = kind
        self.reason = reason
        self.file = file
        self.function = function
        self.line = line
        self.column = column
        self.stackTrace = PolymorphicError.makeStackTrace()
    }

    public static func unableToConvert<T, V>(
        _ value: V, to type: T.Type, file: String = #file, function: String = #function, line: UInt = #line, column: UInt = #column
    ) -> PolymorphicError {
        return PolymorphicError(
            kind: .unableToConvert,
            reason: "Could not convert `\(value)` to `\(T.self)`.",
            file: file,
            function: function,
            line: line,
            column: column
        )
    }

    public static func missingKey<V>(
        _ value: V, path: [String], file: String = #file, function: String = #function, line: UInt = #line, column: UInt = #column
    ) -> PolymorphicError {
        let dot = path.joined(separator: ".")
        return PolymorphicError(
            kind: .missingKey,
            reason: "No value found at path `\(dot)` for value of type `\(V.self)`: \(value).",
            file: file,
            function: function,
            line: line,
            column: column
        )
    }
}

fileprivate enum Kind: String {
    case unableToConvert
    case missingKey
}
