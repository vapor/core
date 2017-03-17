extension ArraySlice where Element == Byte {
    /// Percent decodes an array slice.
    ///
    /// - see: percentDecoded(_: Bytes, nonEncodedTransform: (Byte) -> (Byte)) -> [Byte]
    public func percentDecoded(nonEncodedTransform: (Byte) -> (Byte) = { $0 }) -> Bytes? {
        return Array(self).percentDecoded(nonEncodedTransform: nonEncodedTransform)
    }
}

extension Array where Element == Byte {
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
    public func percentDecoded(nonEncodedTransform: (Byte) -> (Byte) = { $0 }) -> [Byte]? {
        var idx = 0
        var group: [Byte] = []
        while idx < self.count {
            let next = self[idx]
            if next == .percent {
                // %  2  A
                // i +1 +2
                let firstHex = idx + 1
                let secondHex = idx + 2
                idx = secondHex + 1

                guard secondHex < self.count else { return nil }
                let bytes = self[firstHex...secondHex].array

                let str = bytes.makeString()
                guard
                    !str.isEmpty,
                    let encodedByte = Byte(str, radix: 16)
                    else {
                        return nil
                }

                group.append(encodedByte)
            } else {
                let transformed = nonEncodedTransform(next)
                group.append(transformed)
                idx += 1 // don't put outside of else
            }
        }
        return group
    }

    /// Percent encodes an array of bytes.
    ///
    /// - param input: The array of bytes.
    /// - param shouldEncode: Use this to selectively
    /// choose which bytes should be encoded.
    ///
    /// - return: Returns percent-encoded bytes.
    public func percentEncoded(shouldEncode: (Byte) throws -> Bool = { _ in true }) throws -> [Byte] {
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

