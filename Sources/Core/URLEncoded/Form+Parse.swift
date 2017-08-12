import Bits
import Foundation

extension URLEncodedForm {
    static func parse(data: Data) throws -> URLEncodedForm {
        var urlEncoded: [String: URLEncodedForm] = [:]

        for pair in data.split(separator: .ampersand) {
            var value = URLEncodedForm.string("")
            var keyData: Bytes

            /// Allow empty subsequences
            /// value= => "value": ""
            /// value => "value": true
            let token = pair.split(
                separator: .equals,
                maxSplits: 1, // max 1, `foo=a=b` should be `"foo": "a=b"`
                omittingEmptySubsequences: false
            )
            if token.count == 2 {
                keyData = try token[0]
                    .makeString()
                    .replacingOccurrences(of: "+", with: " ")
                    .percentDecoded()
                    .makeBytes()

                let valueData = try token[1]
                    .makeString()
                    .replacingOccurrences(of: "+", with: " ")
                    .percentDecoded()

                value = .string(valueData)
            } else if token.count == 1 {
                keyData = try token[0]
                    .makeString()
                    .replacingOccurrences(of: "+", with: " ")
                    .percentDecoded()
                    .makeBytes()

                value = .string("true")
            } else {
                throw URLCodableError.unexpected(
                    reason: "Unexpected split count when parsing: \(pair.makeString())"
                )
            }

            var keyIndicatedArray = false

            var subKey = ""
            var keyIndicatedObject = false

            // check if the key has `key[]` or `key[5]`
            if keyData.contains(.rightSquareBracket) && keyData.contains(.leftSquareBracket) {
                // get the key without the `[]`
                let slices = keyData
                    .split(separator: .leftSquareBracket, maxSplits: 1)
                guard slices.count == 2 else {
                    print("Found bad encoded pair \(pair.makeString()) ... continuing")
                    continue
                }

                keyData = slices[0].array

                let contents = slices[1].array
                if contents[0] == .rightSquareBracket {
                    keyIndicatedArray = true
                } else {
                    subKey = contents.dropLast().makeString()
                    keyIndicatedObject = true
                }
            }

            let key = keyData.makeString()

            if let existing = urlEncoded[key] {
                if keyIndicatedArray {
                    var array = existing.array ?? [existing]
                    array.append(value)
                    value = .array(array)
                } else if keyIndicatedObject {
                    var obj = existing.dictionary ?? [:]
                    obj[subKey] = value
                    value = .dictionary(obj)
                } else {
                    // if we don't have `[]` on this pair, but it was previously assigned
                    // an array, then it is implicit and should be appended.
                    // OR if we found a subsequent value w/ same identifier, it should
                    // become an array
                    var array = existing.array ?? [existing]
                    array.append(value)
                    value = .array(array)
                }
            } else if keyIndicatedArray {
                value = .array([value])
            } else if keyIndicatedObject {
                value = .dictionary([subKey: value])
            }

            urlEncoded[key] = value
        }

        return .dictionary(urlEncoded)
    }
}

extension String {
    fileprivate func percentDecoded() throws -> String {
        guard let string = self.removingPercentEncoding else {
            throw URLCodableError.unableToPercentDecode(string: self)
        }

        return string
    }
}
