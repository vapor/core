import Foundation

/**
    Objects conforming to this protocol
    can load and save files to a persistent
    data store.
*/
public protocol FileProtocol {
    func load(path: String) throws -> Bytes
    func save(bytes: Bytes, to path: String) throws
}

/**
    Conforms NSData to FileProtocol.
*/
public final class DataFile: FileProtocol {
    public init() { }

    public enum Error: Swift.Error {
        case fileLoad(String)
        case unimplemented
    }

    public func load(path: String) throws -> Bytes {
        guard let data = NSData(contentsOfFile: path) else {
            throw Error.fileLoad(path)
        }
        var bytes = Bytes(repeating: 0, count: data.length)
        data.getBytes(&bytes, length: bytes.count)
        return bytes
    }

    public func save(bytes: Bytes, to path: String) throws {
        throw Error.unimplemented
    }
}
