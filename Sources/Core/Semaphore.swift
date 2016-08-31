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

    #if os(Linux)
    private let semaphore = UnsafeMutablePointer<sem_t>.allocate(capacity: 1)
    #else
    private let semaphore: DispatchSemaphore
    #endif

    /**
        - parameter value: of 0 for 2 threads corresponding, more for specific thread pool.
    */
    public init(value: Int32 = 0) {
        #if os(Linux)
            sem_init(semaphore, 0, UInt32(value))
        #else
            semaphore = DispatchSemaphore(value: Int(value))
        #endif
    }

    deinit {
        #if os(Linux)
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
        #if os(Linux)
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
        #else
            let time = DispatchTime(secondsFromNow: timeout)
            let result = semaphore.wait(timeout: time)
            switch result {
            case .success:
                return .success
            case .timedOut:
                return .timedOut
            }
        #endif
    }

    /**
        Signal waiting semaphores
    */
    public func signal() {
        #if os(Linux)
            sem_post(semaphore)
        #else
            semaphore.signal()
        #endif
    }
}
