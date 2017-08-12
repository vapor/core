import Bits
import Foundation

extension URLEncodedForm {
    func serialize() throws -> Data {
        guard case .dictionary(let dict) = self else {
            throw URLCodableError.unsupportedTopLevel()
        }

        var datas: [Data] = []

        for (key, val) in dict {
            let key = key.formURLEscaped()
            let data: Data

            switch val {
            case .dictionary(let dict):
                var datas: [Data] = []
                try dict.forEach { subKey, value in
                    let subKey = subKey.formURLEscaped()
                    guard let value = value.string else {
                        throw URLCodableError.unsupportedNesting(
                            reason: "Dictionary may only be nested one layer deep."
                        )
                    }

                    let string = "\(key)%5B\(subKey)%5D=\(value)"
                    guard let encoded = string.data(using: .utf8) else {
                        throw URLCodableError.unableToEncode(string: string)
                    }
                    datas.append(encoded)
                }
                data = datas.joined(separatorByte: .ampersand)
            case .array(let array):
                var datas: [Data] = []
                try array.forEach { value in
                    guard let val = value.string else {
                        throw URLCodableError.unsupportedNesting(
                            reason: "Array values may only be nested one layer deep."
                        )
                    }

                    let string = "\(key)%5B%5D=\(val)"
                    guard let encoded = string.data(using: .utf8) else {
                        throw URLCodableError.unableToEncode(string: string)
                    }
                    datas.append(encoded)
                }
                data = datas.joined(separatorByte: .ampersand)
            case .string(let string):
                let string = "\(key)=\(string)"
                guard let encoded = string.data(using: .utf8) else {
                    throw URLCodableError.unableToEncode(string: string)
                }
                data = encoded
            case .null:
                continue
            }

            datas.append(data)
        }

        return datas.joined(separatorByte: .ampersand)
    }
}

// MARK: Utilities

extension Array where Element == Data {
    fileprivate func joined(separatorByte byte: Byte) -> Data {
        return Data(joined(separator: [byte]))
    }
}

extension String {
    fileprivate func formURLEscaped() -> String {
        return addingPercentEncoding(withAllowedCharacters: .formURLEncoded) ?? self
    }
}

extension CharacterSet {
    fileprivate static var formURLEncoded: CharacterSet {
        var set: CharacterSet = .urlQueryAllowed
        set.remove(charactersIn: ":#[]@!$&'()*+,;=")
        return set
    }
}
