import Foundation

extension ByteBuffer {
    public func peekInteger<I>(skipping: Int = 0) -> I? where I: FixedWidthInteger {
        guard readableBytes >= MemoryLayout<I>.size + skipping else {
            return nil
        }
        return getInteger(at: readerIndex + skipping)
    }
}
