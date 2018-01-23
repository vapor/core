import Foundation
import Async
import COperatingSystem
import Bits

public final class File: Socket {
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
        public static let nonblocking = File.Flags(rawValue: O_NONBLOCK)
        
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
    }
    
    public struct Mode {
        var rawValue: mode_t
        
        init(rawValue: mode_t) {
            self.rawValue = rawValue
        }
        
        public static let read = File.Mode(rawValue: numericCast(O_RDONLY))
        public static let write = File.Mode(rawValue: numericCast(O_WRONLY))
        public static let readWrite = File.Mode(rawValue: numericCast(O_RDWR))
    }
    
    public private(set) var descriptor: Int32
    
    public init(atPath path: String, flags: Flags = [.async], mode: Mode = .read, size: Int32) throws {
        self.descriptor = Darwin.open(path, flags.rawValue, mode.rawValue)
        
        guard descriptor >= 0 else {
            let reason = String(cString: strerror(errno))
            throw FileError(identifier: "file", reason: reason)
        }
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
                throw FileError.posix(errno, identifier: "read")
            }
        }
        
        guard receivedBytes > 0 else {
            // receiving 0 indicates the entire file has been read
            self.close()
            return .read(count: 0)
        }
        
        return .read(count: receivedBytes)
    }
    
    /// See `Socket.write`
    public func write(from buffer: ByteBuffer) throws -> SocketWriteStatus {
        guard let pointer = buffer.baseAddress else {
            return .wrote(count: 0)
        }
        
        let sent = send(descriptor, pointer, buffer.count, 0)
        
        guard sent != -1 else {
            switch errno {
            case EINTR:
                // try again
                return try write(from: buffer)
            case EAGAIN, EWOULDBLOCK:
                return .wouldBlock
            default:
                throw FileError.posix(errno, identifier: "write")
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
