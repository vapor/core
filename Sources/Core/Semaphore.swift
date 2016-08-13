import libc
import Foundation

// TODO: Really Darwin vs Glibc, not macOS, find way to use that compiler flag for BSD, EmbeddedSystems, etc. see link: https://github.com/apple/swift-corelibs-foundation/blob/338f4bf3a89c75a0420b49f5701466e106af02b5/CoreFoundation/NumberDate.subproj/CFDate.c#L100

#if os(macOS)
    let info: mach_timebase_info = {
        var info = mach_timebase_info(numer: 0, denom: 0)
        mach_timebase_info(&info)
        return info
    }()

    let NUMER = UInt64(1) // UInt64(info.numer)
    let MY_SEC_PER_SEC = Double(1_000_000_000) // Double(1_000_000_000 * info.numer)

    extension Double {
        var nanoseconds: UInt64 {
            return UInt64(self * MY_SEC_PER_SEC)
        }
    }

    extension DispatchTime {
        init(secondsFromNow: Double) {
            let now = mach_absolute_time() * NUMER
            let nano = secondsFromNow.nanoseconds
            self.init(uptimeNanoseconds: now + nano)
        }
    }

    extension UInt64 {
        var ts: timespec {
            let secs = Int(self / UInt64(MY_SEC_PER_SEC))
            let nsecs = Int(self % UInt64(MY_SEC_PER_SEC))
            return timespec(tv_sec: secs, tv_nsec: nsecs)
        }
    }
#endif


extension timespec {
    internal static var now: timespec {
        #if os(macOS)
            return mach_absolute_time().ts
        #else
            // https://github.com/apple/swift-corelibs-foundation/blob/338f4bf3a89c75a0420b49f5701466e106af02b5/CoreFoundation/NumberDate.subproj/CFDate.c#L104-L107
            var ts = UnsafeMutablePointer<timespec>.allocate(capacity: 1)
            defer { ts.deinitialize() }
            clock_gettime(CLOCK_REALTIME, ts)
            return ts.pointee
        #endif
    }

    internal var timestamp: Double {
        var ts = Double(tv_sec)

        var nsec = Double(tv_nsec)
        while nsec >= 1.0 {
            nsec /= 10
        }

        return ts + nsec
    }

    internal init(secondsFromNow: Double) {
        let total = timespec.now.timestamp + secondsFromNow
        self = total.makeTimespec()
    }
}

extension Double {
    internal func makeTimespec() -> timespec {
        let seconds = Int(self)
        var ts = timespec(tv_sec: seconds, tv_nsec: 0)
        let nsec = self.description
            .components(separatedBy: ".")[safe: 1]
            .flatMap { Int($0)?.makeNanoseconds() }
        if let nsec = nsec {
            ts.tv_nsec = nsec
        }

        return ts
    }
}

extension Int {
    /**
         ugly, but considerably faster than string variant
         
         pads nanoseconds to convert from second fractionals to nano-seconds,
         
         for example:

             3.24 seconds == `3` seconds and `240,000,000` nanoseconds
             5.9810 seconds == `5` seconds and `981,000,000` nanoseconds
     */
    internal func makeNanoseconds() -> Int {
        if self >= 1_000_000_000 { return (self / 10).makeNanoseconds() }
        if self == 0 { return 0 }
        if self < 10 { return self * 100_000_000 }
        if self < 100 { return self * 10_000_000 }
        if self < 1_000 { return self * 1_000_000 }
        if self < 10_000 { return self * 100_000 }
        if self < 100_000 { return self * 10_000 }
        if self < 1_000_000 { return self * 1_000 }
        if self < 10_000_000 { return self * 100 }
        if self < 100_000_000 { return self * 10 }
        return self
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
            sem_init(semaphore, 0, UInt32(value))
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

            /*
                 EDEADLK: Resource deadlock avoided
                 EINTR: Interrupted system call
                 EINVAL: Invalid argument
                 ETIMEDOUT: Connection timed out
            */
            guard wait != -1 else { return .timedOut }
            return .success
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
