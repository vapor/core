import Dispatch
import Foundation
import libc

public final class File: FileReader, FileCache {
    /// Internal dispatch queue
    let queue: DispatchQueue

    /// Cached data.
    /// Only access on self.queue!
    private var cache: [Int: Data]

    /// Holds onto read source handles
    /// Only access on self.queue!
    private var sources: [Int32: DispatchSourceRead]

    /// Holds libc read/write data
    private var buffer: Bytes

    /// Create a new CFile
    /// FIXME: add cache maximum
    public init(on queue: DispatchQueue) {
        self.queue = queue
        self.cache = [:]
        self.sources = [:]
        self.buffer = .init(repeating: 0, count: 1_048_576)
    }

    /// See FileReader.read
    public func read(at path: String) -> Future<Data> {
        let promise = Promise(Data.self)

        let fd = libc.open(path.withCString { $0 }, O_RDONLY | O_NONBLOCK)
        if fd > 0 {
            let readSource = DispatchSource.makeReadSource(
                fileDescriptor: fd,
                queue: queue
            )

            readSource.setEventHandler {
                let bytesRead = libc.read(fd, &self.buffer, self.buffer.count)
                let data = Data(bytes: self.buffer[0..<bytesRead])
                promise.complete(data)
                self.queue.async {
                    self.sources[fd] = nil
                }
            }
            readSource.resume()

            queue.async {
                self.sources[fd] = readSource
            }
        } else {
            promise.fail(FileError(.invalidDescriptor))
        }

        return promise.future;
    }

    /// See FileCache.getFile
    public func getFile<H: Hashable>(hash: H) -> Future<Data?> {
        let promise = Promise(Data?.self)

        queue.async {
            promise.complete(self.cache[hash.hashValue])
        }

        return promise.future
    }

    /// See FileCache.setFile
    public func setFile<H: Hashable>(file: Data?, hash: H) {
        queue.async {
            self.cache[hash.hashValue] = file
        }
    }
}
