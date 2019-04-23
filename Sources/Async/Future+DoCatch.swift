// MARK: Do / Catch

extension Future {
    /// Adds a callback for handling this `Future`'s result when it becomes available.
    ///
    ///     futureString.do { string in
    ///         print(string)
    ///     }.catch { error in
    ///         print("oops: \(error)")
    ///     }
    ///
    /// - warning: Don't forget to use `catch` to handle the error case.
    public func `do`(_ callback: @escaping (T) -> ()) -> Future<T> {
        whenSuccess(callback)
        return self
    }

    /// Adds a callback for handling this `Future`'s result if an error occurs.
    ///
    ///     futureString.do { string in
    ///         print(string)
    ///     }.catch { error in
    ///         print("oops: \(error)")
    ///     }
    ///
    /// - note: Will *only* be executed if an error occurs. Successful results will not call this handler.
    @discardableResult
    public func `catch`(_ callback: @escaping (Error) -> ()) -> Future<T> {
        whenFailure(callback)
        return self
    }

    /// Adds a handler to be asynchronously executed on completion of this future.
    ///
    ///     futureString.do { string in
    ///         print(string)
    ///     }.catch { error in
    ///         print("oops: \(error)")
    ///     }.always {
    ///         print("done")
    ///     }
    ///
    /// - note: Will be executed on both success and failure, but will not receive any input.
    @discardableResult
    public func always(_ callback: @escaping () -> ()) -> Future<T> {
        whenComplete(callback)
        return self
    }
}

extension Collection {
    /// Adds a callback for handling this `[Future]`'s result when it becomes available.
    ///
    ///     futureStrings.do { strings in
    ///         print(strings)
    ///     }.catch { error in
    ///         print("oops: \(error)")
    ///     }
    ///
    /// - warning: Don't forget to use `catch` to handle the error case.
    public func `do`<T>(on worker: Worker, _ callback: @escaping ([T]) -> ()) -> Future<[T]> where Element == Future<T> {
        return self.flatten(on: worker).do(callback)
    }

    /// Adds a callback for handling this `[Future]`'s result if an error occurs.
    ///
    ///     futureStrings.do { strings in
    ///         print(strings)
    ///     }.catch { error in
    ///         print("oops: \(error)")
    ///     }
    ///
    /// - note: Will *only* be executed if an error occurs. Successful results will not call this handler.
    @discardableResult
    public func `catch`<T>(on worker: Worker,_ callback: @escaping (Error) -> ()) -> Future<[T]> where Element == Future<T> {
        return self.flatten(on: worker).catch(callback)
    }


    /// Adds a handler to be asynchronously executed on completion of these futures.
    ///
    ///     futureStrings.do { strings in
    ///         print(strings)
    ///     }.catch { error in
    ///         print("oops: \(error)")
    ///     }.always {
    ///         print("done")
    ///     }
    ///
    /// - note: Will be executed on both success and failure, but will not receive any input.
    @discardableResult
    public func always<T>(on worker: Worker,_ callback: @escaping () -> ()) -> Future<[T]> where Element == Future<T> {
        return self.flatten(on: worker).always(callback)
    }
}

