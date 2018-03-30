extension ByteBuffer {
    /// Reads a null-terminated `String` from this `ByteBuffer`.
    ///
    /// - parameters:
    ///     - encoding: `String.Encoding` to use when converting the bytes to a `String`
    public mutating func readNullTerminatedString(encoding: String.Encoding = .utf8) -> String? {
        var bytes: [UInt8] = []
        parse: while true {
            guard let byte: Byte = readInteger() else {
                return nil
            }
            switch byte {
            case 0: break parse // found null terminator
            default: bytes.append(byte)
            }
        }
        return String(bytes: bytes, encoding: encoding)
    }

    /// Reads a null-terminated `String` from this `ByteBuffer` or throws an error.
    ///
    /// See `readNullTerminatedString(encoding:)`
    public mutating func requireReadNullTerminatedString(encoding: String.Encoding = .utf8) throws -> String {
        guard let string = readNullTerminatedString(encoding: encoding) else {
            throw BitsError(identifier: "nullTerminatedString", reason: "This was not available in the buffer")
        }
        return string
    }
}
