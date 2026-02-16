import Foundation

struct Nft: Codable, Equatable {
    let id: String
    let createdAt: String
    let name: String
    let images: [String]
    let rating: Int
    let description: String
    let price: Double
    let author: String
    let website: String
}

struct CartOrderResponse: Codable {
    let nfts: [String]
    let id: String
}
