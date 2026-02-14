import Foundation

struct NftCollection: Decodable {
    let createdAt: String
    let name: String
    let cover: URL
    let nfts: [String]
    let description: String
    let author: String
    let id: String
}
