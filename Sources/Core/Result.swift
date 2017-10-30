public enum Result<T> {
    case success(T)
    case failure(Error)

    public init(value: T) {
        self = .success(value)
    }

    public init(error: Error) {
        self = .failure(error)
    }
}

extension Result {
    public func extract() throws -> T {
        switch self {
        case .success(let val):
            return val
        case .failure(let e):
            throw e
        }
    }
}

extension Result {
    public var value: T? {
        guard case let .success(val) = self else { return nil }
        return val
    }

    public var error: Error? {
        guard case let .failure(err) = self else { return nil }
        return err
    }
}

extension Result {
    public var succeeded: Bool {
        return value != nil
    }

    public var isSuccess: Bool {
        switch self {
        case .success:
            return true
        default:
            return false
        }
    }

    public var isFailure: Bool {
        switch self {
        case .failure:
            return true
        default:
            return false
        }
    }
}

extension Result: CustomStringConvertible {
    public var description: String {
        switch self {
        case let .success(value): return ".success(\(value))"
        case let .failure(error): return ".failure(\(error))"
        }
    }
}

extension Result: CustomDebugStringConvertible {
    public var debugDescription: String {
        return self.description
    }
}
