import Foundation

extension ByteBuffer {
    /// Peeks into the `ByteBuffer` at the current reader index without changing any state.
    ///
    ///     buffer.peekInteger(as: Int32.self) // Optional(5)
    ///
    /// - parameters:
    ///     - skipping: The amount of bytes to skip, defaults to `0`.
    ///     - type: Optional parameter for specifying the generic `FixedWidthInteger` type.
    public func peekInteger<I>(skipping: Int = 0, as type: I.Type = I.self) -> I? where I: FixedWidthInteger {
        guard readableBytes >= MemoryLayout<I>.size + skipping else {
            return nil
        }
        return getInteger(at: readerIndex + skipping)
    }

    /// Peeks into the `ByteBuffer` at the current reader index without changing any state.
    ///
    ///     buffer.peekString(count: 5) // Optional("hello")
    ///
    /// - parameters:
    ///     - length: Number of bytes to peek.
    ///     - skipping: The amount of bytes to skip, defaults to `0`.
    ///     - encoding: `String.Encoding` to use when converting the bytes to a `String`
    public func peekString(length: Int, skipping: Int = 0, encoding: String.Encoding = .utf8) -> String? {
        guard readableBytes >= length + skipping else { return nil }
        guard let bytes = getBytes(at: readerIndex + skipping, length: length) else { return nil }
        return String(bytes: bytes, encoding: encoding)
    }
    /// Peeks into the `ByteBuffer` at the current reader index without changing any state.
    ///
    ///     buffer.peekFloat(as: Double.self) // Optional(3.14)
    ///
    /// - parameters:
    ///     - skipping: The amount of bytes to skip, defaults to `0`.
    ///     - type: Optional parameter for specifying the generic `BinaryFloatingPoint` type.
    public func peekFloatingPoint<T>(skipping: Int = 0, as: T.Type = T.self) -> T?
        where T: BinaryFloatingPoint
    {
        guard readableBytes >= MemoryLayout<T>.size + skipping else { return nil }
        return  self.withVeryUnsafeBytes { ptr in
            var value: T = 0
            withUnsafeMutableBytes(of: &value) { valuePtr in
                valuePtr.copyMemory(
                    from: UnsafeRawBufferPointer(
                        start: ptr.baseAddress!.advanced(by: skipping + readerIndex),
                        count: MemoryLayout<T>.size
                    )
                )
            }
            return value
        }
    }

    /// Peeks into the `ByteBuffer` at the current reader index without changing any state.
    ///
    ///     buffer.peekData(count: 5) // Optional(5 bytes)
    ///
    /// - parameters:
    ///     - length: Number of bytes to peek.
    ///     - skipping: The amount of bytes to skip, defaults to `0`.
    public func peekData(length: Int, skipping: Int = 0) -> Data? {
        guard readableBytes >= length + skipping else { return nil }
        guard let bytes = getBytes(at: readerIndex + skipping, length: length)
            else { return nil }
        return Data(bytes: bytes)
    }


    /// Peeks into the `ByteBuffer` at the current reader index without changing any state.
    ///
    ///     buffer.peekData(count: 5) // Optional(5 bytes)
    ///
    /// - parameters:
    ///     - count: Number of bytes to peek.
    ///     - skipping: The amount of bytes to skip, defaults to `0`.
    public func peekBytes(count: Int, skipping: Int = 0) -> [UInt8]? {
        guard readableBytes >= count + skipping else { return nil }
        guard let bytes = getBytes(at: readerIndex + skipping, length: count) else { return nil }
        return bytes
    }
}
