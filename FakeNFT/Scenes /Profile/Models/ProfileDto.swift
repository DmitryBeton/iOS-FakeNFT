import Foundation

struct ProfileDto: Dto {
    let name: String
    let description: String
    let avatar: URL?
    let website: URL?
    
    enum CodingKeys: String, CodingKey {
        case name, description, avatar, website
    }
    
    func asDictionary() -> [String : String] {
        let dictionary: [String : String] = [
            CodingKeys.name.rawValue: name,
            CodingKeys.description.rawValue: description,
            CodingKeys.avatar.rawValue: avatar?.absoluteString ?? "",
            CodingKeys.website.rawValue: website?.absoluteString ?? ""
        ]
        return dictionary
    }
}
