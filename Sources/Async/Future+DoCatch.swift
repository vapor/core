extension Future {
    /// Adds a callback for handling this `Future`'s result when it becomes available.
    /// - warning: Don't forget to use `catch` to handle the error case.
    ///
    ///     futureString.do { string in
    ///         print(string)
    ///     }.catch { error in
    ///         print("oops: \(error)")
    ///     }
    ///
    public func `do`(_ callback: @escaping (T) -> ()) -> Future<T> {
        whenSuccess(callback)
        return self
    }

    /// Adds a callback for handling this `Future`'s result if an error occurs.
    /// - note: Will *only* be executed if an error occurs. Successful results will not call this handler.
    ///
    ///     futureString.do { string in
    ///         print(string)
    ///     }.catch { error in
    ///         print("oops: \(error)")
    ///     }
    ///
    @discardableResult
    public func `catch`(_ callback: @escaping (Error) -> ()) -> Future<T> {
        whenFailure(callback)
        return self
    }

    /// Adds a handler to be asynchronously executed on completion of this future.
    /// - note: Will be executed on both success and failure, but will not receive any input.
    ///
    ///     futureString.do { string in
    ///         print(string)
    ///     }.catch { error in
    ///         print("oops: \(error)")
    ///     }.always {
    ///         print("done")
    ///     }
    ///
    @discardableResult
    public func always(_ callback: @escaping () -> ()) -> Future<T> {
        whenComplete(callback)
        return self
    }
}

extension Collection where Element: FutureType {
    /// Adds a callback for handling this `[Future]`'s result when it becomes available.
    /// - warning: Don't forget to use `catch` to handle the error case.
    ///
    ///     futureStrings.do { strings in
    ///         print(strings)
    ///     }.catch { error in
    ///         print("oops: \(error)")
    ///     }
    ///
    public func `do`(on worker: Worker, _ callback: @escaping ([Element.Expectation]) -> ()) -> Future<[Element.Expectation]> {
        return self.flatten(on: worker).do(callback)
    }

    /// Adds a callback for handling this `[Future]`'s result if an error occurs.
    /// - note: Will *only* be executed if an error occurs. Successful results will not call this handler.
    ///
    ///     futureStrings.do { strings in
    ///         print(strings)
    ///     }.catch { error in
    ///         print("oops: \(error)")
    ///     }
    ///
    @discardableResult
    public func `catch`(on worker: Worker,_ callback: @escaping (Error) -> ()) -> Future<[Element.Expectation]> {
        return self.flatten(on: worker).catch(callback)
    }


    /// Adds a handler to be asynchronously executed on completion of these futures.
    /// - note: Will be executed on both success and failure, but will not receive any input.
    ///
    ///     futureStrings.do { strings in
    ///         print(strings)
    ///     }.catch { error in
    ///         print("oops: \(error)")
    ///     }.always {
    ///         print("done")
    ///     }
    ///
    @discardableResult
    public func always(on worker: Worker,_ callback: @escaping () -> ()) -> Future<[Element.Expectation]> {
        return self.flatten(on: worker).always(callback)
    }
}

