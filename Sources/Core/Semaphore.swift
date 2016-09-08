import Dispatch

extension DispatchSemaphore {
    public func wait(timeout: Double) -> DispatchTimeoutResult {
        let time = DispatchTime(secondsFromNow: timeout)
        return wait(timeout: time)
    }
}
