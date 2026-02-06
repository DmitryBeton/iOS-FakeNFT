import Foundation

final class CollectionDetailViewModel {

    // MARK: - Properties

    var onNFTsUpdated: (() -> Void)?
    var onNFTLikeUpdated: ((Int, Bool) -> Void)?

    private(set) var nfts: [NFTCellModel] = []

    let collectionId: String
    let collectionName: String
    let collectionCover: URL?
    let collectionAuthor: String
    let collectionDescription: String

    private let favoritesStorage: FavoritesStorage

    // MARK: - Init

    init(
        collectionId: String,
        collectionName: String,
        collectionCover: URL? = nil,
        collectionAuthor: String = "",
        collectionDescription: String = "",
        favoritesStorage: FavoritesStorage = FavoritesStorageImpl.shared
    ) {
        self.collectionId = collectionId
        self.collectionName = collectionName
        self.collectionCover = collectionCover
        self.collectionAuthor = collectionAuthor
        self.collectionDescription = collectionDescription
        self.favoritesStorage = favoritesStorage
    }

    // MARK: - Public Methods

    func viewDidLoad() {
        loadNFTs()
    }

    func numberOfNFTs() -> Int {
        return nfts.count
    }

    func nft(at index: Int) -> NFTCellModel {
        return nfts[index]
    }

    func toggleLike(at index: Int) {
        guard index < nfts.count else { return }

        let nftId = nfts[index].id
        let newState = favoritesStorage.toggleFavorite(nftId: nftId)
        nfts[index].isLiked = newState

        onNFTLikeUpdated?(index, newState)
    }

    func toggleCart(at index: Int) {
        guard index < nfts.count else { return }
        // TODO: Реализовать логику корзины позже
    }

    // MARK: - Private Methods

    private func loadNFTs() {
        // Mock data для проверки вёрстки
        let mockData: [(id: String, name: String, price: String, rating: Int, isInCart: Bool)] = [
            ("1", "Archie", "1 ETH", 2, false),
            ("2", "Ruby", "1 ETH", 2, true),
            ("3", "Nacho", "1 ETH", 2, false),
            ("4", "Biscuit", "1 ETH", 1, false),
            ("5", "Daisy", "1 ETH", 3, false),
            ("6", "Susan", "1 ETH", 2, false)
        ]

        nfts = mockData.map { item in
            NFTCellModel(
                id: item.id,
                name: item.name,
                imageURL: nil,
                rating: item.rating,
                price: item.price,
                isLiked: favoritesStorage.isFavorite(nftId: item.id),
                isInCart: item.isInCart
            )
        }

        onNFTsUpdated?()
    }
}
