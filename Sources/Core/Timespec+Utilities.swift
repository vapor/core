import libc

extension timespec {
    internal static var now: timespec {
        #if os(Linux)
            var ts = UnsafeMutablePointer<timespec>.allocate(capacity: 1)
            defer { ts.deinitialize() }
            clock_gettime(CLOCK_REALTIME, ts)
            return ts.pointee
        #else
            return mach_absolute_time().ts
        #endif
    }

    internal var timestamp: Double {
        let sec = Double(tv_sec)
        let nsec = Double(tv_nsec) / 1_000_000_000
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
            // MUST pad 0's here for situations like `0.00484` where the leading 0's must be
            // preserved BEFORE mapping to Int.
            .flatMap { Int($0.paddedZeros(targetLength: 9)) }
        if let nsec = nsec {
            ts.tv_nsec = nsec
        }

        return ts
    }
}

extension String {
    func paddedZeros(targetLength: Int) -> String {
        var chars = self.characters.array
        while chars.count < targetLength {
            chars.append("0")
        }
        return String(chars)
    }
}
