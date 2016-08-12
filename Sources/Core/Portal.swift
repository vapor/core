import libc
import Foundation

// TODO: Really Darwin vs Glibc, not macOS, find way to use that compiler flag for BSD, EmbeddedSystems, etc. see link: https://github.com/apple/swift-corelibs-foundation/blob/338f4bf3a89c75a0420b49f5701466e106af02b5/CoreFoundation/NumberDate.subproj/CFDate.c#L100

//let info: mach_timebase_info = {
//    var info = mach_timebase_info(numer: 0, denom: 0)
//    mach_timebase_info(&info)
//    return info
//}()

let NUMER = UInt64(1) // UInt64(info.numer)
let MY_SEC_PER_SEC = Double(1_000_000_000) // Double(1_000_000_000 * info.numer)

extension Double {
    var nanoseconds: UInt64 {
        return UInt64(self * MY_SEC_PER_SEC)
    }
}

#if os(macOS)
    extension DispatchTime {
        init(secondsFromNow: Double) {
            let now = mach_absolute_time() * NUMER
            let nano = secondsFromNow.nanoseconds
            print("NOW: \(now)")
            print("NANO: \(nano)")
            self.init(uptimeNanoseconds: now + nano)
        }
    }
#endif

extension UInt64 {
    var ts: timespec {
        let secs = Int(self / UInt64(MY_SEC_PER_SEC))
        let nsecs = Int(self % UInt64(MY_SEC_PER_SEC))
        return timespec(tv_sec: secs, tv_nsec: nsecs)
    }
}

extension timespec {
    static var now: timespec {
        #if os(macOS)
            return mach_absolute_time().ts
        #else
            // https://github.com/apple/swift-corelibs-foundation/blob/338f4bf3a89c75a0420b49f5701466e106af02b5/CoreFoundation/NumberDate.subproj/CFDate.c#L104-L107
            var ts = UnsafeMutablePointer<timespec>.allocate(capacity: 1)
            defer { ts.deinitialize() }
            clock_gettime(CLOCK_MONOTONIC, ts)
            return ts.pointee
        #endif
    }

    init(secondsFromNow: Double) {
        let nano = secondsFromNow.nanoseconds
        let secs = Int(nano / UInt64(MY_SEC_PER_SEC))
        let nsecs = Int(nano % UInt64(MY_SEC_PER_SEC))
        self.init(tv_sec: secs, tv_nsec: nsecs)

    }
}

public class Semaphore {
    public enum Error: Swift.Error {
        case timedOut
    }

    public enum WaitResult {
        case success
        case timedOut
    }

    #if os(macOS)
    private let semaphore: DispatchSemaphore
    #else
    private let semaphore = UnsafeMutablePointer<sem_t>.allocate(capacity: 1)
    #endif

    public init(value: Int32 = 0) {
        #if os(macOS)
            semaphore = DispatchSemaphore(value: Int(value))
        #else
            print("SEMAPHORE PRE: \(semaphore)")
            sem_init(semaphore, 0, UInt32(value))
            print("SEMAPHORE POST: \(semaphore)")
        #endif
    }

    deinit {
        #if !os(macOS)
            sem_destroy(semaphore)
            semaphore.deinitialize()
        #endif
    }

    // default 1 day
    public func wait(timeout: Double) -> WaitResult {
        #if os(macOS)
            let time = DispatchTime(secondsFromNow: timeout)
            let result = semaphore.wait(timeout: time)
            switch result {
            case .success:
                return .success
            case .timedOut:
                return .timedOut
            }
        #else
            var ts = timespec(secondsFromNow: timeout)
            let wait = sem_timedwait(semaphore, &ts)
            guard wait != -1 else { return .timedOut }
            return .success

//            let nanoseconds = timeout.nanoseconds
//            let sec = nanoseconds / MY_SEC_PER_SEC
//            let nsec = nanoseconds % MY_SEC_PER_SEC
//            let tspointer = UnsafePointer<timespec>.allocate(capacity: 1)
//            defer { tspointer.deinitialize() }
//            clock_gettime(CLOCK_REALTIME, tspointer)
//            // move deallocates
//            var ts = tspointer.move()
//            ts.tv_sec += Int(sec)
//            ts.tv_nsec += Int(nsec)
//            let wait = sem_timedwait(semaphore, ts)
//            guard wait != -1 else { return .timedOut }
        #endif
    }

    public func signal() {
        #if os(macOS)
            semaphore.signal()
        #else
            sem_post(semaphore)
        #endif
    }
}

//extension Date {
//    static func machTime(secondsFromNow: Double) -> mach_timespec_t {
//        let interval = Date(timeIntervalSinceNow: secondsFromNow).timeIntervalSince1970
//        let (seconds, nanoseconds) = interval.timeComponents
//        return mach_timespec_t(tv_sec: seconds, tv_nsec: nanoseconds)
//    }
//}
//
//extension Double {
//    private var timeComponents: (seconds: UInt32, nanoseconds: clock_res_t) {
//        let components = self.description
//            .characters
//            .split(separator: ".", maxSplits: 1)
//            .map { String($0) }
//            .flatMap { UInt32($0) }
//
//        guard components.count >= 2 else { fatalError() }
//        let seconds = components[0]
//
//        // milliseconds => nanoseconds
//        let nanoseconds = clock_res_t(components[1] * 10_000)
//        return (seconds, nanoseconds)
//    }
//}

//#if !os(Linux)

    public enum PortalError: Error {
        case portalNotClosed
        case timedOut
    }

    /**
        This class is designed to make it possible to use asynchronous contexts in a synchronous environment.
    */
    public final class Portal<T> {
        private var result: Result<T>? = .none
        private let semaphore: Semaphore
        private let lock = Core.Lock()

        private init(_ semaphore: Semaphore) {
            self.semaphore = semaphore
        }

        /**
            Close the portal with a successful result
        */
        public func close(with value: T) {
            lock.locked {
                // TODO: Fatal error or throw? It's REALLY convenient NOT to throw here. Should at least log warning
                guard result == nil else { return }
                result = .success(value)
                semaphore.signal()
            }
        }

        /**
            Close the portal with an appropriate error
        */
        public func close(with error: Error) {
            lock.locked {
                guard result == nil else { return }
                result = .failure(error)
                semaphore.signal()
            }
        }

        /**
            Dismiss the portal throwing a portalNotClosed error.
        */
        public func destroy() {
            semaphore.signal()
        }
    }

    extension Portal {
        /**
            This function is used to enter an asynchronous supported context with a portal
            object that can be used to complete a given operation.

                let value = try Portal<Int>.open { portal in
                    // .. do whatever necessary passing around `portal` object
                    // eventually call

                    portal.close(with: 42)

                    // or

                    portal.close(with: errorSignifyingFailure)
                }

            - warning: Calling a `portal` multiple times will have no effect.
        */
        public static func open(
            timeout: Double = ((60 * 60) * 24),
            _ handler: (Portal) throws -> Void
        ) throws -> T {
            let semaphore = Semaphore(value: 0)
            let sender = Portal<T>(semaphore)
            try handler(sender)
            let waitResult = semaphore.wait(timeout: timeout)
            switch waitResult {
            case .success:
                guard let result = sender.result else { throw PortalError.portalNotClosed }
                return try result.extract()
            case .timedOut:
                if let res = sender.result {
                    print("WTF, WE HAVE A THING: \(res)")
                }
                throw PortalError.timedOut
            }
        }
    }

    extension Portal {
        /**
            Execute timeout operations synchronously.
        */
        static func timeout(_ timeout: Double, operation: () throws -> T) throws -> T {
            // TODO: async is locked, it needs to be something like `block` or `lockForAsync`
            return try Portal<T>.open(timeout: timeout) { portal in
                let value = try operation()
                portal.close(with: value)
            }
        }
    }

//#endif
