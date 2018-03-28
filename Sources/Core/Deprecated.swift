@available(*, deprecated, renamed: "ReflectionCodable")
public protocol KeyStringDecodable: ReflectionCodable {
    static var keyStringTrue: Self { get }
    static var keyStringFalse: Self { get }
    static func keyStringIsTrue(_ item: Self) -> Bool
}

extension KeyStringDecodable {
    static func reflectCodable() throws -> (Self, Self) {
        return (keyStringTrue, keyStringFalse)
    }

    public static func reflectCodableIsLeft(_ item: Self) throws -> Bool {
        return keyStringIsTrue(item)
    }
}
