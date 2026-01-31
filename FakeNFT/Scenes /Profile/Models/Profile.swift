import Foundation

struct Profile: Decodable {
    let id: UUID
    let name: String
    let avatar: URL?
    let description: String
    let website: URL?
    let nfts: [UUID]
    let likes: [UUID]
}
