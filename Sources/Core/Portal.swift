// TODO: Needs name that indicates blocking and doesn't break precedence ... RoadBlock?

/*
    Temporarily not available on Linux until Foundation's 'Dispatch apis are available
*/

#if !os(Linux)
    import Foundation

    public enum PortalError: Error {
        case portalNotClosed
        case timedOut
    }

    /**
        This class is designed to make it possible to use asynchronous contexts in a synchronous environment.
    */
    public final class Portal<T> {
        private var result: Result<T>? = .none
        private let semaphore: DispatchSemaphore
        private let lock = Core.Lock()

        private init(_ semaphore: DispatchSemaphore) {
            self.semaphore = semaphore
        }

        /**
            Close the portal with a successful result
        */
        public func close(with value: T) {
            lock.locked {
                // TODO: Fatal error or throw? It's REALLY convenient NOT to throw here. Should at least log warning
                guard result == nil else { return }
                result = .success(value)
                semaphore.signal()
            }
        }

        /**
            Close the portal with an appropriate error
        */
        public func close(with error: Error) {
            lock.locked {
                guard result == nil else { return }
                result = .failure(error)
                semaphore.signal()
            }
        }

        /**
            Dismiss the portal throwing a portalNotClosed error.
        */
        public func destroy() {
            semaphore.signal()
        }
    }

    extension Portal {
        /**
            This function is used to enter an asynchronous supported context with a portal
            object that can be used to complete a given operation.

                let value = try Portal<Int>.open { portal in
                    // .. do whatever necessary passing around `portal` object
                    // eventually call

                    portal.close(with: 42)

                    // or

                    portal.close(with: errorSignifyingFailure)
                }

            - warning: Calling a `portal` multiple times will have no effect.
        */
        public static func open(
            timingOut timeout: DispatchTime = .distantFuture,
            _ handler: (Portal) throws -> Void
        ) throws -> T {
            let semaphore = DispatchSemaphore(value: 0)
            let sender = Portal<T>(semaphore)
            // Ok to call synchronously, since will still unblock semaphore
            // TODO: Find a way to enforce sender is called, not calling will perpetually block w/ long timeout
            try handler(sender)
            let semaphoreResult = semaphore.wait(timeout: timeout)
            switch semaphoreResult {
            case .success:
                guard let result = sender.result else { throw PortalError.portalNotClosed }
                return try result.extract()
            case .timedOut:
                throw PortalError.timedOut
            }
        }
    }

    extension Portal {
        /**
            Execute timeout operations synchronously.
        */
        static func timeout(_ timingOut: DispatchTime, operation: () throws -> T) throws -> T {
            // TODO: async is locked, it needs to be something like `block` or `lockForAsync`
            return try Portal<T>.open(timingOut: timingOut) { portal in
                let value = try operation()
                portal.close(with: value)
            }
        }
    }

#endif
