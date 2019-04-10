/// Represents a single file.
public struct File: Codable {
    /// Name of the file, including extension.
    public var filename: String

    /// The file's data.
    public var data: Data

    /// Associated `MediaType` for this file's extension, if it has one.
    public var contentType: MediaType? {
        return ext.flatMap { MediaType.fileExtension($0.lowercased()) }
    }

    /// The file extension, if it has one.
    public var ext: String? {
        let parts = filename.split(separator: ".")

        if parts.count > 1 {
            return parts.last.map(String.init)
        } else {
            return nil
        }
    }

    /// Creates a new `File`.
    ///
    ///     let file = File(data: "hello", filename: "foo.txt")
    ///
    /// - parameters:
    ///     - data: The file's contents.
    ///     - filename: The name of the file, not including path.
    public init(data: LosslessDataConvertible, filename: String) {
        self.data = data.convertToData()
        self.filename = filename
    }
}
