import Debugging
import NIO
import Foundation

extension ByteBuffer {
    /// Reads a `FixedWidthInteger` from this `ByteBuffer` or throws an error.
    ///
    /// See `readInteger(endianniess:as:)`
    public mutating func requireReadInteger<I>(endianness: Endianness = .big, as: I.Type = I.self) throws -> I where I: FixedWidthInteger {
        guard let i: I = readInteger(endianness: endianness, as: I.self) else {
            throw BitsError(identifier: "requireReadInteger", reason: "Not enough data available in the ByteBuffer.")
        }

        return i
    }

    /// Reads a `String` from this `ByteBuffer` or throws an error.
    ///
    /// See `readString(endianniess:as:)`
    public mutating func requireReadString(length: Int) throws -> String {
        guard let string = readString(length: length) else {
            throw BitsError(identifier: "requireReadString", reason: "Not enough data available in the ByteBuffer.")
        }
        return string
    }

    /// Reads a `Data` from this `ByteBuffer` or throws an error.
    ///
    /// See `readData(endianniess:as:)`
    public mutating func requireReadData(length: Int) throws -> Data {
        guard let bytes = readBytes(length: length) else {
            throw BitsError(identifier: "requireReadData", reason: "Not enough data available in the ByteBuffer.")
        }
        return Data(bytes: bytes)
    }

    /// Reads a `BinaryFloatingPoint` from this `ByteBuffer` or throws an error.
    public mutating func requireReadFloatingPoint<T>(as: T.Type = T.self) throws -> T where T: BinaryFloatingPoint {
        guard let bytes = self.readBytes(length: MemoryLayout<T>.size) else {
            throw BitsError(identifier: "requireReadFloat", reason: "Not enough data available in the ByteBuffer.")
        }
        var value: T = 0
        withUnsafeMutableBytes(of: &value) { valuePtr in
            valuePtr.copyBytes(from: bytes)
        }
        return value
    }
}
