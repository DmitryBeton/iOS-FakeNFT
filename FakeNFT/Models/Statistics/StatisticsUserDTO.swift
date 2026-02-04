import Foundation

struct StatisticsUserDTO: Decodable {
    let id: String
    let name: String
    let avatar: String
    let description: String?
    let website: String
    let nfts: [String]
    let rating: String
}

