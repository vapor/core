@available(*, deprecated, renamed: "ReflectionDecodable")
public protocol KeyStringDecodable: ReflectionDecodable {
    static var keyStringTrue: Self { get }
    static var keyStringFalse: Self { get }
    static func keyStringIsTrue(_ item: Self) -> Bool
}

extension KeyStringDecodable {
    static func reflectDecoded() throws -> (Self, Self) {
        return (keyStringTrue, keyStringFalse)
    }

    public static func reflectDecodedIsLeft(_ item: Self) throws -> Bool {
        return keyStringIsTrue(item)
    }
}
