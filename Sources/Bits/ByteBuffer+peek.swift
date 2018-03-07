import Foundation


// Peek Into FixedWidthInteger
extension ByteBuffer {
    public func peekInteger<I>(skipping: Int = 0) -> I? where I: FixedWidthInteger {
        guard readableBytes >= MemoryLayout<I>.size + skipping else {
            return nil
        }
        return getInteger(at: readerIndex + skipping)
    }
}

// Peek Into String
extension ByteBuffer {
    public func peekString(count: Int,
                           skipping: Int = 0,
                           encoding: String.Encoding) -> String? {
        guard readableBytes >= count + skipping else { return nil }
        guard let bytes = getBytes(at: skipping, length: count) else { return nil }
        return String(bytes: bytes, encoding: encoding)
    }
}

// Peek Into ByteBuffer for Data
extension ByteBuffer {
    public func peekData(count: Int, skipping: Int = 0) -> Data? {
        guard readableBytes >= count + skipping else { return nil }
        guard let bytes = getBytes(at: skipping, length: count)
            else { return nil }
        return Data(bytes: bytes)
    }
}


// Peek Into ByteBuffer for Binary Floating Point
extension ByteBuffer {
    @discardableResult
    public func peekBinaryFloatingPoint<T>(skipping: Int = 0, as: T.Type = T.self) -> T?
        where T: BinaryFloatingPoint
    {
        guard readableBytes >= MemoryLayout<T>.size + skipping else { return nil }
        return  self.withVeryUnsafeBytes { ptr in
            var value: T = 0
            withUnsafeMutableBytes(of: &value) { valuePtr in
                valuePtr.copyMemory(from: UnsafeRawBufferPointer(start: ptr.baseAddress!.advanced(by: skipping),
                                                                 count: MemoryLayout<T>.size))
            }
            return value
        }
    }

}
