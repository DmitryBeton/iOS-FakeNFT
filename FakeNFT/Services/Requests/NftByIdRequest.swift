import Foundation

struct NFTRequest: NetworkRequest {
    let id: String

    var endpoint: URL? {
        URL(string: "\(RequestConstants.baseURL)/api/v1/nft/\(id)")
    }

    var httpMethod: HttpMethod { .get }

    var parameters: [String: String]? { nil }

    var dto: Dto? { nil }
}

