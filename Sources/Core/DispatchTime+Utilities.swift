import libc
import Foundation

#if os(macOS)
private let info: mach_timebase_info = {
    var info = mach_timebase_info(numer: 0, denom: 0)
    mach_timebase_info(&info)
    return info
}()

private let NUMER = UInt64(info.numer)
private let MY_SEC_PER_SEC = Double(1_000_000_000 * info.numer)

extension Double {
    internal var nanoseconds: UInt64 {
        return UInt64(self * MY_SEC_PER_SEC)
    }
}

extension UInt64 {
    internal var ts: timespec {
        let secs = Int(self / UInt64(MY_SEC_PER_SEC))
        let nsecs = Int(self % UInt64(MY_SEC_PER_SEC))
        return timespec(tv_sec: secs, tv_nsec: nsecs)
    }
}

extension DispatchTime {
    public init(secondsFromNow: Double) {
        let now = mach_absolute_time() * NUMER
        let nano = secondsFromNow.nanoseconds
        self.init(uptimeNanoseconds: now + nano)
    }
}
#endif
