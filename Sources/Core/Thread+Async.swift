extension Thread {
    /// Runs the supplied closure on a new thread. Calls `Thread.detachNewThread(_:)`.
    ///
    ///     Thread.async {
    ///         sleep(1)
    ///         print("world!")
    ///     }
    ///     print("Hello, ", terminator: "")
    ///
    /// The above snippet will output:
    ///
    ///     Hello, world!
    ///
    /// - warning: This method will call `fatalError(_:)` on macOS < 10.12.
    ///
    /// Once the work inside the closure has completed, the thread will exit automatically.
    ///
    /// - parameters:
    ///     - work: Closure to be called on new thread.
    public static func async(_ work: @escaping () -> Void) {
        if #available(macOS 10.12, iOS 10.0, tvOS 10.0, watchOS 3.0, *) {
            Thread.detachNewThread(work)
        } else {
            fatalError("macOS 10.12/iOS 10.0/tvOS 10.0/watchOS 3.0 or later required to call Thread.async(_:)")
        }
    }
}
