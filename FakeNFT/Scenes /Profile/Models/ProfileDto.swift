import Foundation

struct ProfileDto: Dto {
    let name: String
    let description: String
    let avatar: URL?
    let website: URL?
    
    private enum Keys: String {
        case name, description, avatar, website
    }
    
    func asDictionary() -> [String : String] {
        let dictionary: [String : String] = [
            Keys.name.rawValue: name,
            Keys.description.rawValue: description,
            Keys.avatar.rawValue: avatar?.absoluteString ?? "",
            Keys.website.rawValue: website?.absoluteString ?? ""
        ]
        return dictionary
    }
}
