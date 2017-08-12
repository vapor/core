import Foundation

public protocol URLDecodable: Decodable {
    static var urlEncodedKeyMap: [String: String?] { get }
}

extension URLDecodable {
    public static var urlEncodedKeyMap: [String: String?] {
        return [:]
    }
}

extension URLDecodable {
    public init(urlEncoded data: Data) throws {
        let form = try URLEncodedForm.parse(data: data)
        let decoder = PolymorphicDecoder<URLEncodedForm>(
            data: form,
            codingPath: [],
            codingKeyMap: Self._keyMap,
            userInfo: [
                .isJSON: true
            ]
        ) { type, data, decoder in
            var codingKeyMap = decoder.codingKeyMap
            if let type = type as? URLDecodable.Type {
                codingKeyMap = type._keyMap
            }

            return PolymorphicDecoder<URLEncodedForm>.init(
                data: data,
                codingPath: decoder.codingPath,
                codingKeyMap: codingKeyMap,
                userInfo: decoder.userInfo,
                factory: decoder.factory
            )
        }

        try self.init(from: decoder)
    }

    public static var jsonKeyMap: [String: String] {
        return [:]
    }

    fileprivate static func _keyMap(key: CodingKey) -> CodingKey? {
        if let mapped = urlEncodedKeyMap[key.stringValue] {
            if let key = mapped {
                return StringKey(key)
            } else {
                return nil
            }
        } else {
            return key
        }
    }
}

