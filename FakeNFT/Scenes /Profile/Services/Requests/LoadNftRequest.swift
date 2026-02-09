import Foundation

struct LoadNftRequest: NetworkRequest {
    let id: UUID
    var endpoint: URL? {
        URL(string: "\(RequestConstants.baseURL)/api/v1/nft/\(id.uuidString)")
    }
    var httpMethod: HttpMethod { .get }
    var dto: Dto? { nil }
}
