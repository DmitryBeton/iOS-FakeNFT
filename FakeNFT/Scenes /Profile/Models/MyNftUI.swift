import Foundation

struct MyNftUI: Identifiable {
    let name: String
    let image: URL?
    let rating: Int
    let price: String
    let author: String
    let isLiked: Bool
    let id: UUID
}
