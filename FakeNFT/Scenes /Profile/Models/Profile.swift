import Foundation

struct Profile: Codable {
    let id: UUID
    let name: String
    let avatar: URL?
    let description: String
    let website: URL?
    let nfts: [UUID]
    let likes: [UUID]
}
