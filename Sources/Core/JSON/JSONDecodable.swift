import Core
import Foundation

public protocol JSONDecodable: Decodable {
    static var jsonKeyMap: [String: String] { get }
}

extension JSONDecodable {
    public init(json data: Data) throws {
        var options: JSONSerialization.ReadingOptions = []
        options.insert(.allowFragments)
        let raw = try JSONSerialization.jsonObject(
            with: data,
            options: options
        )
        let json = JSONData(raw: raw)
        let decoder = PolymorphicDecoder<JSONData>(
            data: json,
            codingPath: [],
            codingKeyMap: Self._jsonKeyMap,
            userInfo: [
                .isJSON: true
            ]
        ) { type, data, decoder in
            var codingKeyMap = decoder.codingKeyMap
            if let type = type as? JSONDecodable.Type {
                codingKeyMap = type._jsonKeyMap
            }

            return PolymorphicDecoder<JSONData>.init(
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

    fileprivate static func _jsonKeyMap(key: CodingKey) -> CodingKey {
        if let mapped = jsonKeyMap[key.stringValue] {
            return StringKey(mapped)
        } else {
            return key
        }
    }
}
