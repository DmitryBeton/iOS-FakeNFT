import Foundation

protocol FavouritesViewModelProtocol: AnyObject {
    var onStateChange: ((FavouritesState) -> Void)? { get set }
    var onLikesUpdate: (() -> Void)? { get set }
    
    var nftsUI: [FavouriteNftUI] { get }
    
    func loadNfts()
    func setLike(id: UUID)
}
