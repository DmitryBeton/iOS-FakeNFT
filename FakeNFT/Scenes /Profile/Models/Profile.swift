import Foundation

struct Profile: Decodable {
    let id: UUID
    let name: String
    let avatar: URL?
    let description: String
    let website: URL?
    let nfts: [UUID]
    let likes: [UUID]
    
    private enum CodingKeys: String, CodingKey {
        case id, name, avatar, description, website, nfts, likes
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        id = try container.decode(UUID.self, forKey: .id)
        name = try container.decode(String.self, forKey: .name)
        description = try container.decode(String.self, forKey: .description)
        nfts = try container.decode([UUID].self, forKey: .nfts)
        likes = try container.decode([UUID].self, forKey: .likes)
        
        let avatarString = try container.decode(String.self, forKey: .avatar)
        avatar = URL(string: avatarString)
        
        let websiteString = try container.decode(String.self, forKey: .website)
        website = URL(string: websiteString)
    }
}
