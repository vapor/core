import libc
import Foundation
import Dispatch

extension Double {
    internal var nanoseconds: UInt64 {
        return UInt64(self * Double(NSEC_PER_SEC))
    }
}

extension UInt64 {
    internal var ts: timespec {
        let secs = Int(self / UInt64(NSEC_PER_SEC))
        let nsecs = Int(self % UInt64(NSEC_PER_SEC))
        return timespec(tv_sec: secs, tv_nsec: nsecs)
    }
}

extension timespec {
    internal var nanoseconds: UInt64 {
        let seconds = UInt64(tv_sec) * NSEC_PER_SEC
        let nanos = UInt64(tv_nsec)
        return seconds + nanos
    }
}

extension DispatchTime {
    /**
        Create a dispatch time for a given seconds from now.
    */
    public init(secondsFromNow: Double) {
        let nano = timespec(secondsFromNow: secondsFromNow)
        self.init(uptimeNanoseconds: nano.nanoseconds)
    }
}
