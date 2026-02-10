import Foundation

enum HttpMethod: String {
    case get = "GET"
    case post = "POST"
    case put = "PUT"
    case delete = "DELETE"
}

protocol NetworkRequest {
    var endpoint: URL? { get }
    var httpMethod: HttpMethod { get }
    var dto: Dto? { get }
    var headers: [String: String]? { get }
    var body: Data? { get }
    var contentType: String? { get }
}

protocol Dto {
    func asDictionary() -> [String: String]
}

// default values
extension NetworkRequest {
    var httpMethod: HttpMethod { .get }
    var dto: Dto? { nil }
    var headers: [String: String]? { nil }
    var body: Data? { nil }
    var contentType: String? { nil }
}
