/// Represents a header value with optional parameter metadata.
///
/// Parses a header string like `application/json; charset="utf8"`, into:
///
/// - value: `"application/json"`
/// - parameters: ["charset": "utf8"]
public struct HeaderValue {
    /// The `HeaderValue`'s main value.
    ///
    /// In the `HeaderValue` `"application/json; charset=utf8"`:
    ///
    /// - value: `"application/json"`
    public let value: String

    /// The `HeaderValue`'s metadata. Zero or more key/value pairs.
    ///
    /// In the `HeaderValue` `"application/json; charset=utf8"`:
    ///
    /// - parameters: ["charset": "utf8"]
    public let parameters: [String: String]

    /// Parse a `HeaderValue` from a `String`.
    ///
    ///     guard let headerValue = HeaderValue.parse("application/json; charset=utf8") else { ... }
    ///
    public static func parse(_ string: String) -> HeaderValue? {
        /// separate the zero or more parameters
        let parts = string.split(separator: ";", maxSplits: 1)

        /// there must be at least one part, the value
        guard let value = parts.first else {
            /// should never hit this
            return nil
        }

        /// get the remaining parameters string
        var remaining: Substring

        switch parts.count {
        case 1:
            /// no parameters, early exit
            return HeaderValue(value: .init(value), parameters: [:])
        case 2: remaining = parts[1]
        default: return nil
        }

        /// collect all of the parameters
        var parameters: [String: String] = [:]

        /// loop over all parts after the value
        parse: while remaining.count > 0 {
            /// parse the parameters by splitting on the `=`
            let parameterParts = remaining.split(separator: "=", maxSplits: 1)

            let key = parameterParts[0].trimmingCharacters(in: .whitespaces)

            switch parameterParts.count {
            case 1:
                parameters[key] = ""
                break parse
            case 2: break
            default:
                /// the parameter was not form `foo=bar`
                return nil
            }

            let trailing = parameterParts[1].trimmingCharacters(in: .whitespaces)

            let val: String
            if trailing.first == "\"" {
                /// find first unescaped quote
                var quoteIndex: String.Index?
                findQuote: for i in 1..<trailing.count {
                    let prev = trailing.index(trailing.startIndex, offsetBy: i - 1)
                    let curr = trailing.index(trailing.startIndex, offsetBy: i)
                    if trailing[prev] != "\\" && trailing[curr] == "\"" {
                        quoteIndex = curr
                        break findQuote
                    }
                }

                guard let i = quoteIndex else {
                    /// could never find a closing quote
                    return nil
                }
                val = .init(trailing[trailing.index(after: trailing.startIndex)..<i])
                let rest = trailing[trailing.index(after: i)...]
                if let nextSemicolon = rest.index(of: ";") {
                    remaining = rest[rest.index(after: nextSemicolon)...]
                } else {
                    remaining = ""
                }
            } else {
                /// find first semicolon
                var semicolonIndex: String.Index?
                findSemicolon: for i in 0..<trailing.count {
                    let curr = trailing.index(trailing.startIndex, offsetBy: i)
                    if trailing[curr] == ";" {
                        semicolonIndex = curr
                        break findSemicolon
                    }
                }

                if let i = semicolonIndex {
                    /// cut to next semicolon
                    val = trailing[trailing.startIndex..<i].trimmingCharacters(in: .whitespaces)
                    remaining = trailing[trailing.index(after: i)...]
                } else {
                    /// no more semicolons
                    val = trailing.trimmingCharacters(in: .whitespaces)
                    remaining = ""
                }
            }

            parameters[.init(key)] = val
        }

        return HeaderValue(value: .init(value), parameters: parameters)
    }
}


