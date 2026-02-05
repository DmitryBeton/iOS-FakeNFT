import Foundation

struct UserByIdRequest: NetworkRequest {
    let id: String

    var endpoint: URL? {
        URL(string: "\(RequestConstants.baseURL)/api/v1/users/\(id)")
    }

    var httpMethod: HttpMethod { .get }
    var dto: Dto? { nil }
}

