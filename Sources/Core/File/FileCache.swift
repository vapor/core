import Foundation

/// Capable of caching file data asynchronously.
public protocol FileCache {
    // Fetches the file from the cache
    func getFile<H: Hashable>(hash: H) -> Future<Data?>

    /// Sets the file into the cache
    func setFile<H: Hashable>(file: Data?, hash: H)
}

extension FileReader where Self: FileCache {
    /// Checks the cache for the file path or reads
    /// it from the reader.
    public func cachedRead(at path: String) -> Future<Data> {
        let promise = Promise(Data.self)

        getFile(hash: path).then { data in
            if let data = data {
                promise.complete(data)
            } else {
                self.read(at: path).then { data in
                    self.setFile(file: data, hash: path)
                    promise.complete(data)
                }.catch { error in
                    promise.fail(error)
                }
            }
        }.catch { error in
            promise.fail(error)
        }

        return promise.future
    }
}
