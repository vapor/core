import libc
import Foundation
import Dispatch

#if os(Linux)
    let CLOCKS = CLOCKS_PER_SEC
#else
    let CLOCKS = NSEC_PER_SEC
#endif
extension Double {
    internal var nanoseconds: UInt64 {
        return UInt64(self * Double(CLOCKS))
    }
}

extension UInt64 {
    internal var ts: timespec {
        let secs = Int(self / UInt64(CLOCKS))
        let nsecs = Int(self % UInt64(CLOCKS))
        return timespec(tv_sec: secs, tv_nsec: nsecs)
    }
}

extension timespec {
    internal var nanoseconds: UInt64 {
        let seconds = UInt64(tv_sec) * UInt64(CLOCKS)
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
