/// Errors that can be thrown from Polymorphic methods.
public struct PolymorphicError: Error {
    public let reason: String

    public init(reason: String) {
        self.reason = reason
    }

    public static func unableToConvert<T, V>(_ value: V, to type: T.Type) -> PolymorphicError {
        return PolymorphicError(reason: "Could not convert `\(value)` to `\(T.self)`.")
    }

    public static func missingKey<V>(_ value: V, path: [String]) -> PolymorphicError {
        let dot = path.joined(separator: ".")
        return PolymorphicError(
            reason: "No value found at path `\(dot)` for value of type `\(V.self)`: \(value)."
        )
    }
}
