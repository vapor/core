// MARK: Variadic

extension Future {
    /// Calls the supplied callback when both futures have completed.
    ///
    ///     return Future.map(futureA, futureB) { a, b in
    ///         // ...
    ///     }
    ///
    public static func map<A, B, Result>(
        _ futureA: Future<A>,
        _ futureB: Future<B>,
        to result: Result.Type,
        _ callback: @escaping (A, B) throws -> (Result)
    ) -> Future<Result> {
        return futureA.flatMap(to: Result.self) { a in
            return futureB.map(to: Result.self) { b in
                return try callback(a, b)
            }
        }
    }

    /// Calls the supplied callback when both futures have completed.
    ///
    ///     return Future.flatMap(futureA, futureB) { a, b in
    ///         // ...
    ///     }
    ///
    public static func flatMap<A, B, Result>(
        _ futureA: Future<A>,
        _ futureB: Future<B>,
        to result: Result.Type,
        _ callback: @escaping (A, B) throws -> Future<Result>
    ) -> Future<Result> {
        return futureA.flatMap(to: Result.self) { a in
            return futureB.flatMap(to: Result.self) { b in
                return try callback(a, b)
            }
        }
    }

    /// Calls the supplied callback when all three futures have completed.
    ///
    ///     return Future.map(futureA, futureB, futureC) { a, b, c in
    ///         // ...
    ///     }
    ///
    public static func map<A, B, C, Result>(
        _ futureA: Future<A>,
        _ futureB: Future<B>,
        _ futureC: Future<C>,
        to result: Result.Type,
        _ callback: @escaping (A, B, C) throws -> Result
    ) -> Future<Result> {
        return futureA.flatMap(to: Result.self) { a in
            return futureB.flatMap(to: Result.self) { b in
                return futureC.map(to: Result.self) { c in
                    return try callback(a, b, c)
                }
            }
        }
    }

    /// Calls the supplied callback when all three futures have completed.
    ///
    ///     return Future.flatMap(futureA, futureB, futureC) { a, b, c in
    ///         // ...
    ///     }
    ///
    public static func flatMap<A, B, C, Result>(
        _ futureA: Future<A>,
        _ futureB: Future<B>,
        _ futureC: Future<C>,
        to result: Result.Type,
        _ callback: @escaping (A, B, C) throws -> Future<Result>
    ) -> Future<Result> {
        return futureA.flatMap(to: Result.self) { a in
            return futureB.flatMap(to: Result.self) { b in
                return futureC.flatMap(to: Result.self) { c in
                    return try callback(a, b, c)
                }
            }
        }
    }

    /// Calls the supplied callback when all four futures have completed.
    ///
    ///     return Future.map(futureA, futureB, futureC, futureD) { a, b, c, d in
    ///         // ...
    ///     }
    ///
    public static func map<A, B, C, D, Result>(
        _ futureA: Future<A>,
        _ futureB: Future<B>,
        _ futureC: Future<C>,
        _ futureD: Future<D>,
        to result: Result.Type,
        _ callback: @escaping (A, B, C, D) throws -> Result
    ) -> Future<Result> {
        return futureA.flatMap(to: Result.self) { a in
            return futureB.flatMap(to: Result.self) { b in
                return futureC.flatMap(to: Result.self) { c in
                    return futureD.map(to: Result.self) { d in
                        return try callback(a, b, c, d)
                    }
                }
            }
        }
    }

    /// Calls the supplied callback when all four futures have completed.
    ///
    ///     return Future.flatMap(futureA, futureB, futureC, futureD) { a, b, c, d in
    ///         // ...
    ///     }
    ///
    public static func flatMap<A, B, D, C, Result>(
        _ futureA: Future<A>,
        _ futureB: Future<B>,
        _ futureC: Future<C>,
        _ futureD: Future<D>,
        to result: Result.Type,
        _ callback: @escaping (A, B, C, D) throws -> (Future<Result>)
    ) -> Future<Result> {
        return futureA.flatMap(to: Result.self) { a in
            return futureB.flatMap(to: Result.self) { b in
                return futureC.flatMap(to: Result.self) { c in
                    return futureD.flatMap(to: Result.self) { d in
                        return try callback(a, b, c, d)
                    }
                }
            }
        }
    }

    /// Calls the supplied callback when all five futures have completed.
    ///
    ///     return Future.map(futureA, futureB, futureC, futureD, futureE) { a, b, c, d, e in
    ///         // ...
    ///     }
    ///
    public static func map<A, B, C, D, E, Result>(
        _ futureA: Future<A>,
        _ futureB: Future<B>,
        _ futureC: Future<C>,
        _ futureD: Future<D>,
        _ futureE: Future<E>,
        to result: Result.Type,
        _ callback: @escaping (A, B, C, D, E) throws -> Result
    ) -> Future<Result> {
        return futureA.flatMap(to: Result.self) { a in
            return futureB.flatMap(to: Result.self) { b in
                return futureC.flatMap(to: Result.self) { c in
                    return futureD.flatMap(to: Result.self) { d in
                        return futureE.map(to: Result.self) { e in
                            return try callback(a, b, c, d, e)
                        }
                    }
                }
            }
        }
    }

    /// Calls the supplied callback when all five futures have completed.
    ///
    ///     return Future.flatMap(futureA, futureB, futureC, futureD, futureE) { a, b, c, d, e in
    ///         // ...
    ///     }
    ///
    public static func flatMap<A, B, D, C, E, Result>(
        _ futureA: Future<A>,
        _ futureB: Future<B>,
        _ futureC: Future<C>,
        _ futureD: Future<D>,
        _ futureE: Future<E>,
        to result: Result.Type,
        _ callback: @escaping (A, B, C, D, E) throws -> (Future<Result>)
    ) -> Future<Result> {
        return futureA.flatMap(to: Result.self) { a in
            return futureB.flatMap(to: Result.self) { b in
                return futureC.flatMap(to: Result.self) { c in
                    return futureD.flatMap(to: Result.self) { d in
                        return futureE.flatMap(to: Result.self) { e in
                            return try callback(a, b, c, d, e)
                        }
                    }
                }
            }
        }
    }
}
