import Foundation

extension ByteBuffer {
    public func peekInteger<I>(skipping: Int = 0) -> I? where I: FixedWidthInteger {
        return getInteger(at: readerIndex + skipping)
    }
}
