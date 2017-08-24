import Dispatch
import Foundation
import libc

public final class File: FileReader, FileCache {
    /// Cached data.
    private var cache: [Int: Data]

    /// Create a new CFile
    /// FIXME: add cache maximum
    public init() {
        self.cache = [:]
    }

    /// See FileReader.read
    public func read(at path: String) -> Future<Data> {
        let promise = Promise(Data.self)

        let file = DispatchIO(
            type: .stream,
            path: "/Users/tanner/Desktop/hello.txt",
            oflag: O_RDONLY,
            mode: 0,
            queue: .global()
        ) { error in
            if error == 0 {
                // success
            } else {
                let error = FileError(.readError(error, path: path))
                promise.fail(error)
            }
        }

        if let file = file {
            var buffer = DispatchData.empty
            file.read(offset: 0, length: size_t.max - 1, queue: .global()) { done, data, error in
                if done {
                    if error == 0 {
                        let copied = Data(buffer)
                        promise.complete(copied)
                    } else {
                        let error = FileError(.readError(error, path: path))
                        promise.fail(error)
                    }
                } else {
                    if let data = data {
                        buffer.append(data)
                    } else {
                        let error = FileError(.readError(error, path: path))
                        promise.fail(error)
                    }
                }
            }
        } else {
            promise.fail(FileError(.invalidDescriptor))
        }

        return promise.future;
    }

    /// See FileCache.getFile
    public func getFile<H: Hashable>(hash: H) -> Future<Data?> {
        return Future(cache[hash.hashValue])
    }

    /// See FileCache.setFile
    public func setFile<H: Hashable>(file: Data?, hash: H) {
        cache[hash.hashValue] = file
    }
}


extension DispatchData {
    static let empty = DispatchData(
        bytes: UnsafeRawBufferPointer(start: nil, count: 0)
    )
}
