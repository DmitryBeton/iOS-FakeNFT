import Foundation

struct FavouriteNftUI: Identifiable, Hashable {
    let name: String
    let image: URL?
    let rating: Int
    let price: String
    let id: UUID
    let isLiked: Bool
}
