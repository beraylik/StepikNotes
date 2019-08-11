import Foundation

struct ApiError: Error {
    let error: NetworkError
}

enum NetworkError {
    case unreachable
    case badStatusCode
    case unreadableData
}

class BaseBackendOperation: AsyncOperation {
    override init() {
        super.init()
    }
}
