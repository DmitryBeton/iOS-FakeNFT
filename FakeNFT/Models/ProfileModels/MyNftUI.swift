import Foundation

struct MyNftUI: Identifiable, Hashable {
    let name: String
    let image: URL?
    let rating: Int
    let price: String
    let author: String
    let id: UUID
    let isLiked: Bool
}
