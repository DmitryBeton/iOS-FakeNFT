import Foundation

struct NFTCellModel {
    let id: String
    let name: String
    let imageURL: URL?
    let rating: Int
    let price: String
    var isLiked: Bool
    var isInCart: Bool
}
