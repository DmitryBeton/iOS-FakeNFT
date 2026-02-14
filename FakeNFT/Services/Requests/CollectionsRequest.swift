import Foundation

struct CollectionsRequest: NetworkRequest {
    var dto: (any Dto)?
    
    var endpoint: URL? {
        URL(string: "\(RequestConstants.baseURL)/api/v1/collections")
    }
}
