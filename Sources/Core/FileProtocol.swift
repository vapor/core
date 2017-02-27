import Foundation
@_exported import Debugging

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
    public enum Error: Debuggable {
        case create(path: String)
        case load(path: String)
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
        guard let data = NSData(contentsOfFile: path) else {
            throw Error.load(path: path)
        }

        var bytes = Bytes(repeating: 0, count: data.length)
        data.getBytes(&bytes, length: bytes.count)
        return bytes
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
        guard success else { throw Error.create(path: path) }
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

extension DataFile.Error {
    public var identifier: String {
        switch self {
        case .create:
            return "create"
        case .load:
            return "load"
        case .unspecified:
            return "unspecified"
        }
    }

    public var reason: String {
        switch self {
        case .create(let path):
            return "unable to create the file at path \(path)"
        case .load(let path):
            return "unable to load file at path \(path)"
        case .unspecified(let error):
            return "received an unspecified or extended error: \(error)"
        }
    }

    public var possibleCauses: [String] {
        switch self {
        case .create:
            return [
                "no have write permissions at specified path",
                "attempted to write corrupted data",
                "system issue"
            ]
        case .load:
            return [
                "file doesn't exist",
                "data read is corrupted",
                "system issue"
            ]
        case .unspecified:
            return [
                "received an error not originally supported by this version"
            ]
        }
    }

    public var suggestedFixes: [String] {
        return [
            "ensure that file permissions are correct for specified paths"
        ]
    }

    public var documentationLinks: [String] {
        return [
            "https://developer.apple.com/reference/foundation/filemanager",
        ]
    }
}
