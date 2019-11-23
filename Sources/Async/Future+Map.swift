// MARK: Map

extension Future {
    /// Maps a `Future` to a `Future` of a different type.
    ///
    /// - note: The result returned within should be non-`Future` type.
    ///
    ///     print(futureString) // Future<String>
    ///     let futureInt = futureString.map(to: Int.self) { string in
    ///         print(string) // The actual String
    ///         return Int(string) ?? 0
    ///     }
    ///     print(futureInt) // Future<Int>
    ///
    /// See `flatMap(to:_:)` for mapping `Future` results to other `Future` types.
    public func map<T>(to type: T.Type = T.self, _ callback: @escaping (Expectation) throws -> T) -> Future<T> {
        return self.thenThrowing(callback)
    }

    /// Maps a `Future` to a `Future` of a different type.
    ///
    /// - note: The result returned within the closure should be another `Future`.
    ///
    ///     print(futureURL) // Future<URL>
    ///     let futureRes = futureURL.flatMap(to: Response.self) { url in
    ///         print(url) // The actual URL
    ///         return client.get(url: url) // Returns Future<Response>
    ///     }
    ///     print(futureRes) // Future<Response>
    ///
    /// See `map(to:_:)` for mapping `Future` results to non-`Future` types.
    public func flatMap<T>(to type: T.Type = T.self, _ callback: @escaping (Expectation) throws -> Future<T>) -> Future<T> {
        return self.then { input in
            do {
                return try callback(input)
            } catch {
                return self.eventLoop.newFailedFuture(error: error)
            }
        }
    }
    
    /// Calls the supplied closure if the chained Future resolves to an Error.
    ///
    /// The closure gives you a chance to rectify the error (returning the desired expectation)
    /// or to re-throw or throw a different error.
    ///
    /// The callback expects a non-Future return (if not throwing instead). See `catchFlatMap` for a Future return.
    public func catchMap(_ callback: @escaping (Error) throws -> (Expectation)) -> Future<Expectation> {
        return self.thenIfErrorThrowing(callback)
    }


    /// Calls the supplied closure if the chained Future resolves to an Error.
    ///
    /// The closure gives you a chance to rectify the error (returning the desired expectation)
    /// or to re-throw or throw a different error.
    ///
    /// The callback expects a Future return (if not throwing instead). See `catchMap` for a non-Future return.
    ///
    ///      return conn.query("BEGIN TRANSACTION").flatMap {
    ///          return transaction.run(on: connection).flatMap {
    ///              return conn.query("END TRANSACTION")
    ///          }.catchFlatMap { error in
    ///              return conn.query("ROLLBACK").map {
    ///                  throw error
    ///              }
    ///          }
    ///      }
    ///
    public func catchFlatMap(_ callback: @escaping (Error) throws -> (Future<Expectation>)) -> Future<Expectation> {
        return self.thenIfError { inputError in
            do {
                return try callback(inputError)
            } catch {
                return self.eventLoop.newFailedFuture(error: error)
            }
        }
    }
}
