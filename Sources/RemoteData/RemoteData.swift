public enum RemoteData<T> {
    case notAsked
    case loading
    case success(T)
    case failure(Swift.Error)

    public var isNotAsked: Bool {
        switch self {
        case .notAsked:
            return true
        default:
            return false
        }
    }

    public var isLoading: Bool {
        switch self {
        case .loading:
            return true
        default:
            return false
        }
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

    public var isResolved: Bool {
        isSuccess || isFailure
    }

    public var toOption: T? {
        switch self {
        case let .success(t):
            return .some(t)
        default:
            return .none
        }
    }

    public var toError: Error? {
        switch self {
        case let .failure(e):
            return .some(e)
        default:
            return .none
        }
    }

    public func get() throws -> T? {
        switch self {
        case .notAsked, .loading:
            return .none
        case let .success(t):
            return .some(t)
        case let .failure(e):
            throw e
        }
    }

    public func map<U>(_ closure: (T) throws -> U) -> RemoteData<U> {
        switch self {
        case let .success(t):
            do {
                return .success(try closure(t))
            }
            catch {
                return .failure(error)
            }
        case .notAsked:
            return .notAsked
        case .loading:
            return .loading
        case let .failure(e):
            return .failure(e)
        }
    }

    public func mapError(_ closure: (Swift.Error) -> Swift.Error) -> RemoteData<T> {
        switch self {
        case .success, .loading, .notAsked:
            return self
        case let .failure(e):
            return .failure(closure(e))
        }
    }

    public func `catch`(_ closure: (Swift.Error) throws -> T) -> RemoteData<T> {
        switch self {
        case .success, .loading, .notAsked:
            return self
        case let .failure(e):
            do {
                return .success(try closure(e))
            }
            catch {
                return .failure(error)
            }
        }
    }

    public func andMap<U>(_ nextData: RemoteData<U>) -> RemoteData<(T, U)> {
        do {
            let a = try self.get()
            let b = try nextData.get()
            if let a = a, let b = b {
                return .success((a, b))
            }
            else if self.isLoading || nextData.isLoading {
                return .loading
            }
            else {
                return .notAsked
            }
        }
        catch {
            return .failure(error)
        }
    }
}

extension RemoteData: Equatable where T: Equatable {
    public static func == (lhs: RemoteData<T>, rhs: RemoteData<T>) -> Bool {
        if lhs.isNotAsked && rhs.isNotAsked {
            return true
        }
        if lhs.isLoading && rhs.isLoading {
            return true
        }
        if let lhs = lhs.toOption, let rhs = rhs.toOption {
            return lhs == rhs
        }
        // having two RemoteData with the same error still doesn't feel like
        // they are "the same" to me – like comparing NULL in SQL, it's just
        // always false
        return false
    }
}

public func untuple<A, B>(_ tuple: (A, B)) -> (A, B) { (tuple.0, tuple.1) }
public func untuple<A, B, C>(_ tuple: ((A, B), C)) -> (A, B, C) { (tuple.0.0, tuple.0.1, tuple.1) }
public func untuple<A, B, C, D>(_ tuple: (((A, B), C), D)) -> (A, B, C, D) { (tuple.0.0.0, tuple.0.0.1, tuple.0.1, tuple.1) }
public func untuple<A, B, C, D, E>(_ tuple: ((((A, B), C), D), E)) -> (A, B, C, D, E) { (tuple.0.0.0.0, tuple.0.0.0.1, tuple.0.0.1, tuple.0.1, tuple.1) }
public func untuple<A, B, C, D, E, F>(_ tuple: (((((A, B), C), D), E), F)) -> (A, B, C, D, E, F) { (tuple.0.0.0.0.0, tuple.0.0.0.0.1, tuple.0.0.0.1, tuple.0.0.1, tuple.0.1, tuple.1) }
public func untuple<A, B, C, D, E, F, G>(_ tuple: ((((((A, B), C), D), E), F), G)) -> (A, B, C, D, E, F, G) { (tuple.0.0.0.0.0.0, tuple.0.0.0.0.0.1, tuple.0.0.0.0.1, tuple.0.0.0.1, tuple.0.0.1, tuple.0.1, tuple.1) }
public func untuple<A, B, C, D, E, F, G, H>(_ tuple: (((((((A, B), C), D), E), F), G), H)) -> (A, B, C, D, E, F, G, H) { (tuple.0.0.0.0.0.0.0, tuple.0.0.0.0.0.0.1, tuple.0.0.0.0.0.1, tuple.0.0.0.0.1, tuple.0.0.0.1, tuple.0.0.1, tuple.0.1, tuple.1) }
public func untuple<A, B, C, D, E, F, G, H, I>(_ tuple: ((((((((A, B), C), D), E), F), G), H), I)) -> (A, B, C, D, E, F, G, H, I) { (tuple.0.0.0.0.0.0.0.0, tuple.0.0.0.0.0.0.0.1, tuple.0.0.0.0.0.0.1, tuple.0.0.0.0.0.1, tuple.0.0.0.0.1, tuple.0.0.0.1, tuple.0.0.1, tuple.0.1, tuple.1) }
public func untuple<A, B, C, D, E, F, G, H, I, J>(_ tuple: (((((((((A, B), C), D), E), F), G), H), I), J)) -> (A, B, C, D, E, F, G, H, I, J) { (tuple.0.0.0.0.0.0.0.0.0, tuple.0.0.0.0.0.0.0.0.1, tuple.0.0.0.0.0.0.0.1, tuple.0.0.0.0.0.0.1, tuple.0.0.0.0.0.1, tuple.0.0.0.0.1, tuple.0.0.0.1, tuple.0.0.1, tuple.0.1, tuple.1) }
public func untuple<A, B, C, D, E, F, G, H, I, J, K>(_ tuple: ((((((((((A, B), C), D), E), F), G), H), I), J), K)) -> (A, B, C, D, E, F, G, H, I, J, K) { (tuple.0.0.0.0.0.0.0.0.0.0, tuple.0.0.0.0.0.0.0.0.0.1, tuple.0.0.0.0.0.0.0.0.1, tuple.0.0.0.0.0.0.0.1, tuple.0.0.0.0.0.0.1, tuple.0.0.0.0.0.1, tuple.0.0.0.0.1, tuple.0.0.0.1, tuple.0.0.1, tuple.0.1, tuple.1) }
