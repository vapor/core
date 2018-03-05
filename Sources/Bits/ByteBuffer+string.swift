extension ByteBuffer {
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

    public mutating func requireReadNullTerminatedString(encoding: String.Encoding = .utf8, or error: @autoclosure () -> Error) throws -> String {
        guard let string = readNullTerminatedString(encoding: encoding) else {
            throw error()
        }
        return string
    }
}
