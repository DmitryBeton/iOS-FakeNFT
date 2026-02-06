import Foundation

struct ProfileNft: Decodable {
    let createdAt: Date
    let name: String
    let images: [URL]
    let rating: Int
    let description: String
    let price: Decimal
    let author: String
    let website: URL
    let id: UUID
}
