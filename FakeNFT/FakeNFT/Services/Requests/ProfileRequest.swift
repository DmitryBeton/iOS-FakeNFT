import Foundation

struct ProfileRequest: NetworkRequest {
    var endpoint: URL? {
        URL(string: "\(RequestConstants.baseURL)/api/v1/profile/1")
    }

    var httpMethod: HttpMethod { .get }
    var parameters: [String: String]? { nil }
    var dto: Dto? { nil }
}

