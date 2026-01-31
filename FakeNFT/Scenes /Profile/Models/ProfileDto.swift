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
        var dictionary: [String : String] = [
            CodingKeys.name.rawValue: name,
            CodingKeys.description.rawValue: description
        ]
        if let avatar {
            let avatarString = avatar.absoluteString
            dictionary.updateValue(avatarString, forKey: CodingKeys.avatar.rawValue)
        }
        if let website {
            let websiteString = website.absoluteString
            dictionary.updateValue(websiteString, forKey: CodingKeys.website.rawValue)
        }
        return dictionary
    }
}
