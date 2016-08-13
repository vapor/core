import libc
import Foundation

/**
    A Linux supported basic implementation of Semaphore
*/
public class Semaphore {

    /**
        The result of a Semaphore's wait call
    */
    public enum WaitResult {
        case success
        case timedOut
    }

    #if os(macOS)
    private let semaphore: DispatchSemaphore
    #else
    private let semaphore = UnsafeMutablePointer<sem_t>.allocate(capacity: 1)
    #endif

    /**
        - parameter value: of 0 for 2 threads corresponding, more for specific thread pool.
    */
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

    /*
        Wait on the current thread until the semaphore has been signaled

        - parameter timeout: seconds from now
        - return: the result of the underlying wait operation
    */
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

    /**
        Signal waiting semaphores
    */
    public func signal() {
        #if os(macOS)
            semaphore.signal()
        #else
            sem_post(semaphore)
        #endif
    }
}
