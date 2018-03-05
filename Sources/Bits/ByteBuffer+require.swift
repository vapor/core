extension ByteBuffer {
    public mutating func requireReadInteger<I>(or error: @autoclosure () -> Error) throws -> I where I: FixedWidthInteger {
        guard let i: I = readInteger() else {
            throw error()
        }
        return i
    }
}
