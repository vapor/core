extension ByteBuffer {
    public mutating func requireReadInteger<I>(or error: Error) throws -> I where I: FixedWidthInteger {
        guard let i: I = readInteger() else {
            throw error
        }
        return i
    }
}
