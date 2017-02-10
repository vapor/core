import Foundation

/**
    Objects conforming to this protocol
    can load and save files to a persistent
    data store.
*/
public protocol FileProtocol {
    /**
        Load the bytes at a given path
    */
    func load(path: String) throws -> Bytes

    /**
        Save the bytes to a given path
    */
    func save(bytes: Bytes, to path: String) throws

    /**
        Deletes the file at a given path
    */
    func delete(at path: String) throws
}

/**
    Basic Foundation implementation of FileProtocols
*/
public final class DataFile: FileProtocol {
    public enum Error: Swift.Error {
        case createFailed
        case unspecified(Swift.Error)
    }

    /**
        ...
    */
    public init() { }

    /**
        @see - FileProtocol.load
    */
    public func load(path: String) throws -> Bytes {
        let url = URL(fileURLWithPath: path)
        let data = try Data(contentsOf: url)
        return data.makeBytes()
    }

    /**
        @see - FileProtocol.save
    */
    public func save(bytes: Bytes, to path: String) throws {
        if !fileExists(at: path) {
            try create(at: path, bytes: bytes)
        } else {
            try write(to: path, bytes: bytes)
        }
    }

    /**
        @see - FileProtocol.delete
    */
    public func delete(at path: String) throws {
        try FileManager.default.removeItem(atPath: path)
    }

    private func create(at path: String, bytes: Bytes) throws {
        let data = Data(bytes: bytes)
        let success = FileManager.default.createFile(
            atPath: path,
            contents: data,
            attributes: nil
        )
        guard success else { throw Error.createFailed }
    }

    private func fileExists(at path: String) -> Bool {
        return FileManager.default.fileExists(atPath: path)
    }

    private func write(to path: String, bytes: Bytes) throws {
        let bytes = Data(bytes: bytes)

        let url = URL(fileURLWithPath: path)
        try bytes.write(to: url)
    }
}

extension DataFile {
    /**
        Load the bytes at a given path
    */
    public static func load(path: String) throws -> Bytes {
        return try DataFile().load(path: path)
    }

    /**
        Save the bytes to a given path
    */
    public static func save(bytes: Bytes, to path: String) throws {
        try DataFile().save(bytes: bytes, to: path)
    }

    /**
        Deletes the file at a given path
    */
    public static func delete(at path: String) throws {
        try DataFile().delete(at: path)
    }
}
