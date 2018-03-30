import struct NIO.ByteBuffer

/// A `Byte` is an 8-bit unsigned integer.
public typealias Byte = UInt8

/// `Bytes` are a Swift array of 8-bit unsigned integers.
public typealias Bytes = [Byte]

/// `BytesBufferPointer` are a Swift `UnsafeBufferPointer` to 8-bit unsigned integers.
public typealias BytesBufferPointer = UnsafeBufferPointer<Byte>

/// `MutableBytesBufferPointer` are a Swift `UnsafeMutableBufferPointer` to 8-bit unsigned integers.
public typealias MutableBytesBufferPointer = UnsafeMutableBufferPointer<Byte>

/// `BytesPointer` are a Swift `UnsafePointer` to 8-bit unsigned integers.
public typealias BytesPointer = UnsafePointer<Byte>

/// `MutableBytesPointer` are a Swift `UnsafeMutablePointer` to 8-bit unsigned integers.
public typealias MutableBytesPointer = UnsafeMutablePointer<Byte>

/// `ByteBuffer` is a typealias to NIO's `ByteBuffer`.
public typealias ByteBuffer = NIO.ByteBuffer

/// Implements pattern matching for `Byte` to `Byte?`.
public func ~=(pattern: Byte, value: Byte?) -> Bool {
    return pattern == value
}

extension Byte {
    /// Returns the `String` representation of this `Byte` (unicode scalar).
    public var string: String {
        let unicode = Unicode.Scalar(self)
        let char = Character(unicode)
        return String(char)
    }
}
