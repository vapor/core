import Debugging
import NIO
import Foundation

class ByteBufferReadError: Debuggable {
    public static let readableName = "Byte Buffer Read Error"
    public let identifier: String
    public var reason: String
    public var sourceLocation: SourceLocation?
    public var stackTrace: [String]
    public var possibleCauses: [String]
    public var suggestedFixes: [String]

    public init(
        identifier: String,
        reason: String,
        possibleCauses: [String] = [],
        suggestedFixes: [String] = [],
        source: SourceLocation
        ) {
        self.identifier = identifier
        self.reason = reason
        self.sourceLocation = source
        self.stackTrace = ByteBufferReadError.makeStackTrace()
        self.possibleCauses = possibleCauses
        self.suggestedFixes = suggestedFixes
    }
}

// Read In Integer In Whatever Endianness you wish
extension ByteBuffer {
    public mutating func requireReadInteger<I>(endianness: Endianness = .big) throws -> I where I: FixedWidthInteger {
        guard let i: I = readInteger(endianness: endianness, as: I.self) else {
            throw ByteBufferReadError(identifier: "Error Reading FixedWidthInteger",
                                      reason: "This was not available in the buffer",
                                      possibleCauses: ["Buffer was already read",
                                                       "Buffer was not checked before reading"],
                                      suggestedFixes: ["Before each buffer read use the peak functions included to insure the bytes needed are their"],
                                      source: .capture())
        }
        return i
    }
}

//Read In String
extension ByteBuffer {
    public mutating func requireReadString(length: Int) throws -> String {
        guard let string = readString(length: length) else {
        throw ByteBufferReadError(identifier: "Error Reading String",
                                  reason: "This was not available in the buffer",
                                  possibleCauses: ["Buffer was already read",
                                                   "Buffer was not checked before reading"],
                                  suggestedFixes: ["Before each buffer read use the peak functions included to insure the bytes needed are their"],
                                  source: .capture())
        }
        return string
    }
}

//Read In Data
extension ByteBuffer {
    public mutating func requireReadData(length: Int) throws -> Data {
        guard let bytes = readBytes(length: length) else {
            throw ByteBufferReadError(identifier: "Error Reading Data",
                                      reason: "This was not available in the buffer",
                                      possibleCauses: ["Buffer was already read",
                                                       "Buffer was not checked before reading"],
                                      suggestedFixes: ["Before each buffer read use the peak functions included to insure the bytes needed are their"],
                                      source: .capture())
        }
        return Data(bytes: bytes)
    }
}

//Read In BinaryFloatingPoint

extension ByteBuffer {
    @discardableResult
    public mutating func  requireBinaryFloatingPoint<T>(as: T.Type = T.self) throws -> T
        where T: BinaryFloatingPoint
    {
        guard let bytes = self.readBytes(length: MemoryLayout<T>.size) else {
            throw ByteBufferReadError(identifier: "Error Reading Binary Floating Point",
                                      reason: "This was not available in the buffer",
                                      possibleCauses: ["Buffer was already read",
                                                       "Buffer was not checked before reading"],
                                      suggestedFixes: ["Before each buffer read use the peak functions included to insure the bytes needed are their"],
                                      source: .capture())
        }
        var value: T = 0
        withUnsafeMutableBytes(of: &value) { valuePtr in
            valuePtr.copyBytes(from: bytes)
        }
        return value
    }
}
