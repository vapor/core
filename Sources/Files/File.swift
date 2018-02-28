import Foundation
import Async
import COperatingSystem
import Bits

public final class File {
    public struct Flags: OptionSet {
        public typealias RawValue = Int32
        
        public var rawValue: Int32
        
        public init(rawValue: RawValue) {
            self.rawValue = rawValue
        }
        
        /// Offsets the cursor to the end of the file (like `lseek`)
        ///
        /// Do _not_ use with NFS to prevent corruption
        public static let append = File.Flags(rawValue: O_APPEND)
        
        /// Read the file asynchronously, generating a signal by default
        public static let async = File.Flags(rawValue: O_ASYNC)
        
        /// Open the file in nonblocking mode
        public static let nonBlocking = File.Flags(rawValue: O_NONBLOCK)
        
        /// The file mustbe created. Throw an error if it already exists
        public static let mustCreate = File.Flags(rawValue: O_DIRECTORY)
        
        /// Creates the file if it doesn't yet exist
        public static let mayCreate = File.Flags(rawValue: O_CREAT)
        
        /// The file accessed _must_ be a directory
        public static let requireDirectory = File.Flags(rawValue: O_DIRECTORY)
        
        /// If this path is a symbolic link, do not follow it
        public static let disallowSymbolic = File.Flags(rawValue: O_NOFOLLOW)
        
        /// Does not update the last access time
        public static let avoidTouchingAccessTime = File.Flags(rawValue: O_NOFOLLOW)
        
        /// Opens the file for reading only
        public static let read = File.Flags(rawValue: numericCast(O_RDONLY))
        
        /// Opens the file for writing only
        public static let write = File.Flags(rawValue: numericCast(O_WRONLY))
        
        /// Opens the file for reading and writing
        public static let readWrite = File.Flags(rawValue: numericCast(O_RDWR))
    }
    
    public struct Details {
        let stat: stat
        
        public var size: Int {
            return numericCast(stat.st_size)
        }
        
        public var lastModification: Date {
            let epochSeconds = Double(stat.st_mtimespec.tv_nsec) * 1_000_000_000
            
            return Date(timeIntervalSince1970: epochSeconds)
        }
        
        public var lastAccess: Date {
            let epochSeconds = Double(stat.st_atimespec.tv_nsec) * 1_000_000_000
            
            return Date(timeIntervalSince1970: epochSeconds)
        }
        
        init(_ stat: stat) {
            self.stat = stat
        }
    }
    
    public private(set) var descriptor: Int32
    var offset: off_t = 0
    public let details: Details
    
    /// Opens a new file to the `path` using the provided flags
    public init(atPath path: String, flags: Flags) throws {
        self.descriptor = COperatingSystem.open(path, flags.rawValue)
        
        guard descriptor >= 0 else {
            let reason = String(cString: strerror(errno))
            throw FileError(identifier: "file", reason: reason, sourceLocation: .capture())
        }
        
        var status = stat()
        
        guard fstat(self.descriptor, &status) == 0 else {
            throw FileError.posix(errno, identifier: "fstat", sourceLocation: .capture())
        }
        
        self.details = Details(status)
    }
    
    /// Sets the offset of the file to `offset` using `lseek`
    public func setOffset(to offset: off_t) {
        lseek(self.descriptor, offset, SEEK_SET)
        self.offset = offset
    }
    
    /// TODO: Expose this API if there's demand
    internal func advanceOffset(by offset: off_t) {
        lseek(self.descriptor, offset, SEEK_CUR)
        self.offset += offset
    }
    
    /// See `Socket.read`
    public func read(into buffer: MutableByteBuffer) throws -> SocketReadStatus {
        let receivedBytes = COperatingSystem.read(descriptor, buffer.baseAddress!, buffer.count)
        
        guard receivedBytes != -1 else {
            switch errno {
            case EINTR:
                // try again
                return try read(into: buffer)
            case EAGAIN, EWOULDBLOCK:
                // no data yet
                return .wouldBlock
            default:
                throw FileError.posix(errno, identifier: "read", sourceLocation: .capture())
            }
        }
        
        offset += numericCast(receivedBytes)
        return .read(count: receivedBytes)
    }
    
    /// See `Socket.write`
    public func write(from buffer: ByteBuffer) throws -> SocketWriteStatus {
        guard let pointer = buffer.baseAddress else {
            return .wrote(count: 0)
        }
        
        let sent = COperatingSystem.write(descriptor, pointer, buffer.count)
        
        guard sent != -1 else {
            switch errno {
            case EINTR:
                // try again
                return try write(from: buffer)
            case EAGAIN, EWOULDBLOCK:
                return .wouldBlock
            default:
                throw FileError.posix(errno, identifier: "write", sourceLocation: .capture())
            }
        }
        
        return .wrote(count: sent)
    }
    
    /// See `Socket.close`
    public func close() {
        guard self.descriptor != -1 else { return }
        
        COperatingSystem.close(self.descriptor)
        self.descriptor = -1
    }
}

#if os(Linux)
    /// This extension simplifies API differences between Linux and Darwin
    fileprivate extension stat {
        var st_atimespec: time_t {
            return self.st_atime
        }
        
        var st_mtimespec: time_t {
            return self.st_mtime
        }
    }
#endif
