public enum RemoteData<T> {
    case notAsked
    case loading
    case success(T)
    case failure(Swift.Error)

    var isNotAsked: Bool {
        switch self {
        case .notAsked:
            return true
        default:
            return false
        }
    }

    var isLoading: Bool {
        switch self {
        case .loading:
            return true
        default:
            return false
        }
    }

    var isSuccess: Bool {
        switch self {
        case .success:
            return true
        default:
            return false
        }
    }

    var isFailure: Bool {
        switch self {
        case .failure:
            return true
        default:
            return false
        }
    }

    var toOption: T? {
        switch self {
        case let .success(t):
            return .some(t)
        default:
            return .none
        }
    }

    func map<U>(_ closure: (T) throws -> U) -> RemoteData<U> {
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
}
