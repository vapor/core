/// Objects conforming to this protocol
/// can load and save files to a persistent
/// data store.
public protocol FileProtocol {
    /// Load the bytes at a given path
    func load(path: String) throws -> Bytes

    /// Save the bytes to a given path
    func save(bytes: Bytes, to path: String) throws

    /// Deletes the file at a given path
    func delete(at path: String) throws
}

extension FileProtocol where Self: EmptyInitializable {
    /// Load the bytes at a given path
    public static func load(path: String) throws -> Bytes {
        return try Self().load(path: path)
    }
    
    /// Save the bytes to a given path
    public static func save(bytes: Bytes, to path: String) throws {
        try Self().save(bytes: bytes, to: path)
    }
    
    /// Deletes the file at a given path
    public static func delete(at path: String) throws {
        try Self().delete(at: path)
    }
}
