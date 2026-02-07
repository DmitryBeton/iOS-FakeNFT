import Foundation

protocol MyNftViewModelProtocol: AnyObject {
    var onStateChange: ((MyNftState) -> Void)? { get set }
    var onSortChange: (() -> Void)? { get set }
    var onLikesUpdate: (() -> Void)? { get set }
    
    var sortedNfts: [MyNftUI] { get }
    
    func loadNfts()
    func changeSort(_ sort: SortOption)
    func setLike(id: UUID)
}
