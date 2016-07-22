public protocol BytesRepresentable {
    func makeBytes() throws -> Bytes
}

public protocol BytesInitializable {
    init(bytes: Bytes) throws
}

public protocol BytesConvertible: BytesRepresentable, BytesInitializable { }

extension String: BytesConvertible {
    public func makeBytes() throws -> Bytes {
        return bytes
    }

    public init(bytes: Bytes) throws {
        self = bytes.string
    }
}

import Foundation

extension Data: BytesConvertible {
    public func makeBytes() throws -> Bytes {
        var array = Bytes(repeating: 0, count: count)
        let buffer = UnsafeMutableBufferPointer(start: &array, count: count)
        _ = copyBytes(to: buffer)
        return array
    }
}
