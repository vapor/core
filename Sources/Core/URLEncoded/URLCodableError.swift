public struct URLCodableError: Error {
    fileprivate let kind: Kind
    public let reason: String

    fileprivate init(kind: Kind, reason: String) {
        self.kind = kind
        self.reason = reason
    }

    public static func unsupportedTopLevel() -> URLCodableError {
        return .init(
            kind: .unsupportedTopLevel,
            reason: "Only dictionary case is supported as top level URLEncodedForm."
        )
    }

    public static func unsupportedNesting(reason: String) -> URLCodableError {
        return .init(
            kind: .unsupportedNesting,
            reason: "Unsupported nesting: \(reason)"
        )
    }

    public static func unableToEncode(string: String) -> URLCodableError {
        return .init(
            kind: .unableToEncode,
            reason: "Unable to encode: \(string)"
        )
    }

    public static func unableToPercentDecode(string: String) -> URLCodableError {
        return .init(
            kind: .unableToPercentDecode,
            reason: "Unable to percent decode: \(string)"
        )
    }

    public static func unexpected(reason: String) -> URLCodableError {
        return .init(
            kind: .unexpected,
            reason: reason
            
        )
    }
}

fileprivate enum Kind: String {
    case unsupportedNesting
    case unableToEncode
    case unableToPercentDecode
    case unsupportedTopLevel
    case unexpected
}
