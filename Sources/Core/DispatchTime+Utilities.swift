import libc
import Foundation
import Dispatch

extension Double {
    internal var nanoseconds: UInt64 {
        return UInt64(self * 1_000_000_000)
    }
}

extension UInt64 {
    internal var ts: timespec {
        let secs = Int(self / UInt64(1_000_000_000))
        let nsecs = Int(self % UInt64(1_000_000_000))
        return timespec(tv_sec: secs, tv_nsec: nsecs)
    }
}

extension timespec {
    internal var nanoseconds: UInt64 {
        let seconds = UInt64(tv_sec) * 1_000_000_000
        let nanos = UInt64(tv_nsec)
        return seconds + nanos
    }
}

extension DispatchTime {
    /**
        Create a dispatch time for a given seconds from now.
    */
    public init(secondsFromNow: Double) {
        let now = timespec.now.nanoseconds
        let nano = secondsFromNow.nanoseconds
        self.init(uptimeNanoseconds: now + nano)
    }
}
