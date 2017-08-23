import Foundation

/// Capable of reading files async.
public protocol FileReader {
    /// Reads the file at the supplied path
    func read(at path: String) -> Future<Data>
}
