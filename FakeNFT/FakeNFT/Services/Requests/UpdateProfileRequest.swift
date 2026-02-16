import Foundation

struct UpdateProfileRequest: NetworkRequest {
    let dto: Dto?

    var endpoint: URL? {
        URL(string: "\(RequestConstants.baseURL)/api/v1/profile/1")
    }

    var httpMethod: HttpMethod { .put }
}

struct UpdateProfileDto: Dto {
    let name: String
    let avatar: String
    let description: String?
    let website: String
    let likes: [String]

    func asDictionary() -> [String : String] {
        var dict: [String: String] = [
            "name": name,
            "avatar": avatar,
            "website": website,
            "likes": String(data: try! JSONEncoder().encode(likes), encoding: .utf8) ?? "[]"
        ]
        if let description { dict["description"] = description }
        return dict
    }
}

