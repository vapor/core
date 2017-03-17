import Foundation

extension Sequence where Iterator.Element == Byte {
    /// Percent decodes an array of bytes.
    ///
    /// - param input: The percent encoded array of bytes.
    /// - param nonEncodedTransform: Converts non percent-encoded
    /// bytes by passing through the clsoure.
    /// This is useful for cases like converting `+`
    /// to spaces in percent-encoded URL strings.
    ///
    /// - return: Returns the decoded array of bytes
    /// or returns `nil` if the bytes could not
    /// be decoded.
    @available(*, deprecated: 1.0, message: "use foundation apis directly")
    public func percentDecoded(nonEncodedTransform: (Byte) -> (Byte) = { $0 }) -> Bytes? {
        return self.map(nonEncodedTransform).makeString().removingPercentEncoding?.makeBytes()
    }

    /// Percent encodes an array of bytes.
    ///
    /// - param input: The array of bytes.
    /// - param shouldEncode: Use this to selectively
    /// choose which bytes should be encoded.
    ///
    /// - return: Returns percent-encoded bytes.
    @available(*, deprecated: 1.0, message: "use foundation apis directly")
    public func percentEncoded(shouldEncode: (Byte) throws -> Bool = { _ in true }) throws -> Bytes? {
        var group: [Byte] = []
        try self.forEach { byte in
            if try shouldEncode(byte) {
                let hex = String(byte, radix: 16).utf8
                group.append(.percent)
                if hex.count == 1 {
                    group.append(.zero)
                }
                group.append(contentsOf: hex)
            } else {
                group.append(byte)
            }
        }
        return group
    }
}

