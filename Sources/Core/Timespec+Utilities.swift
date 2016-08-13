import libc

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
        let sec = Double(tv_sec)

        var nsec = Double(tv_nsec)
        while nsec >= 1.0 {
            nsec /= 10
        }

        return sec + nsec
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
