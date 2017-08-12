public typealias JSONCodable = JSONDecodable & JSONEncodable

extension Array: JSONCodable {
    public static var jsonKeyMap: [String: String] {
        if let type = Element.self as? JSONCodable.Type {
            return type.jsonKeyMap
        } else {
            return [:]
        }
    }
}

extension Dictionary: JSONCodable {
    public static var jsonKeyMap: [String: String] {
        if let type = Value.self as? JSONCodable.Type {
            return type.jsonKeyMap
        } else {
            return [:]
        }
    }
}

extension Optional: JSONCodable {
    public static var jsonKeyMap: [String: String] {
        if let type = Wrapped.self as? JSONCodable.Type {
            return type.jsonKeyMap
        } else {
            return [:]
        }
    }
}

extension CodingUserInfoKey {
    public static var isJSON: CodingUserInfoKey {
        return CodingUserInfoKey(rawValue: "JSON")!
    }
}
