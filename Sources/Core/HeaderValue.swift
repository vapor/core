/// Represents a header value with optional parameter metadata.
///
/// Parses a header string like `application/json; charset="utf8"`, into:
///
/// - value: `"application/json"`
/// - parameters: ["charset": "utf8"]
///
/// Simplified format:
///
///     headervalue := value *(";" parameter)
///     ; Matching of media type and subtype
///     ; is ALWAYS case-insensitive.
///
///     value := token
///
///     parameter := attribute "=" value
///
///     attribute := token
///     ; Matching of attributes
///     ; is ALWAYS case-insensitive.
///
///     token := 1*<any (US-ASCII) CHAR except SPACE, CTLs,
///         or tspecials>
///
///     value := token
///     ; token MAY be quoted
///
///     tspecials :=  "(" / ")" / "<" / ">" / "@" /
///                   "," / ";" / ":" / "\" / <">
///                   "/" / "[" / "]" / "?" / "="
///     ; Must be in quoted-string,
///     ; to use within parameter values
public struct HeaderValue {
    /// Internal storage.
    internal let _value: Data

    /// The `HeaderValue`'s main value.
    ///
    /// In the `HeaderValue` `"application/json; charset=utf8"`:
    ///
    /// - value: `"application/json"`
    public var value: String {
        return String(data: _value, encoding: .utf8) ?? ""
    }

    /// The `HeaderValue`'s metadata. Zero or more key/value pairs.
    ///
    /// In the `HeaderValue` `"application/json; charset=utf8"`:
    ///
    /// - parameters: ["charset": "utf8"]
    public var parameters: [CaseInsensitiveString: String]

    /// Creates a new `HeaderValue`.
    public init(_ value: LosslessDataConvertible, parameters: [CaseInsensitiveString: String] = [:]) {
        self._value = value.convertToData()
        self.parameters = parameters
    }

    /// Serializes this `HeaderValue` to a `String`.
    public func serialize() -> String {
        var string = "\(value)"
        for (key, val) in parameters {
            string += "; \(key)=\"\(val)\""
        }
        return string
    }

    /// Parse a `HeaderValue` from a `String`.
    ///
    ///     guard let headerValue = HeaderValue.parse("application/json; charset=utf8") else { ... }
    ///
    public static func parse(_ data: LosslessDataConvertible) -> HeaderValue? {
        let data = data.convertToData()

        /// separate the zero or more parameters
        let parts = data.split(separator: .semicolon, maxSplits: 1)

        /// there must be at least one part, the value
        guard let value = parts.first else {
            /// should never hit this
            return nil
        }

        /// get the remaining parameters string
        var remaining: Data

        switch parts.count {
        case 1:
            /// no parameters, early exit
            return HeaderValue(value, parameters: [:])
        case 2: remaining = parts[1]
        default: return nil
        }

        /// collect all of the parameters
        var parameters: [CaseInsensitiveString: String] = [:]

        /// loop over all parts after the value
        parse: while remaining.count > 0 {
            let semicolon = remaining.index(of: .semicolon)
            let equals = remaining.index(of: .equals)

            let key: Data
            let val: Data

            if equals == nil || (equals != nil && semicolon != nil && semicolon! < equals!) {
                /// parsing a single flag, without =
                key = remaining[remaining.startIndex..<(semicolon ?? remaining.endIndex)]
                val = .init()
                if let s = semicolon {
                    remaining = remaining[remaining.index(after: s)...]
                } else {
                    remaining = .init()
                }
            } else {
                /// parsing a normal key=value pair.
                /// parse the parameters by splitting on the `=`
                let parameterParts = remaining.split(separator: .equals, maxSplits: 1)

                key = parameterParts[0]

                switch parameterParts.count {
                case 1:
                    val = .init()
                    remaining = .init()
                case 2:
                    let trailing = parameterParts[1]

                    if trailing.first == .quote {
                        /// find first unescaped quote
                        var quoteIndex: Data.Index?
                        var escapedIndexes: [Data.Index] = []
                        findQuote: for i in 1..<trailing.count {
                            let prev = trailing.index(trailing.startIndex, offsetBy: i - 1)
                            let curr = trailing.index(trailing.startIndex, offsetBy: i)
                            if trailing[curr] == .quote {
                                if trailing[prev] != .backSlash {
                                    quoteIndex = curr
                                    break findQuote
                                } else {
                                    escapedIndexes.append(prev)
                                }
                            }
                        }

                        guard let i = quoteIndex else {
                            /// could never find a closing quote
                            return nil
                        }

                        var valpart = trailing[trailing.index(after: trailing.startIndex)..<i]

                        if escapedIndexes.count > 0 {
                            /// go reverse so that we can correctly remove multiple
                            for escapeLoc in escapedIndexes.reversed() {
                                valpart.remove(at: escapeLoc)
                            }
                        }

                        val = valpart

                        let rest = trailing[trailing.index(after: trailing.startIndex)...]
                        if let nextSemicolon = rest.index(of: .semicolon) {
                            remaining = rest[rest.index(after: nextSemicolon)...]
                        } else {
                            remaining = .init()
                        }
                    } else {
                        /// find first semicolon
                        var semicolonOffset: Data.Index?
                        findSemicolon: for i in 0..<trailing.count {
                            let curr = trailing.index(trailing.startIndex, offsetBy: i)
                            if trailing[curr] == .semicolon {
                                semicolonOffset = curr
                                break findSemicolon
                            }
                        }

                        if let i = semicolonOffset {
                            /// cut to next semicolon
                            val = trailing[trailing.startIndex..<i]
                            remaining = trailing[trailing.index(after: i)...]
                        } else {
                            /// no more semicolons
                            val = trailing
                            remaining = .init()
                        }
                    }
                default:
                    /// the parameter was not form `foo=bar`
                    return nil
                }
            }

            let trimmedKey = String(data: key, encoding: .utf8)?.trimmingCharacters(in: .whitespaces) ?? ""
            let trimmedVal = String(data: val, encoding: .utf8)?.trimmingCharacters(in: .whitespaces) ?? ""
            parameters[.init(trimmedKey)] = .init(trimmedVal)
        }

        return HeaderValue(value, parameters: parameters)
    }
}
