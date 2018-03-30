extension ByteBuffer {
    /// Write `integer` into this `ByteBuffer`, moving the writer index forward appropriately.
    ///
    /// - parameters:
    ///     - integer: The integer to serialize.
    ///     - endianness: The endianness to use, defaults to big endian.
    /// - returns: The number of bytes written.
    @discardableResult
    public mutating func write<T>(floatingPoint: T) -> Int where T: BinaryFloatingPoint {
        let bytesWritten = self.set(floatingPoint: floatingPoint, at: self.writerIndex)
        self.moveWriterIndex(forwardBy: bytesWritten)
        return Int(bytesWritten)
    }

    /// Write `integer` into this `ByteBuffer` starting at `index`. This does not alter the writer index.
    ///
    /// - parameters:
    ///     - integer: The integer to serialize.
    ///     - index: The index of the first byte to write.
    ///     - endianness: The endianness to use, defaults to big endian.
    /// - returns: The number of bytes written.
    @discardableResult
    public mutating func set<T>(floatingPoint: T, at index: Int) -> Int where T: BinaryFloatingPoint {
        var value = floatingPoint
        return Swift.withUnsafeBytes(of: &value) { ptr in
            self.set(bytes: ptr, at: index)
        }
    }
}
