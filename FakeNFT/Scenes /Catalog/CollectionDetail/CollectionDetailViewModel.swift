import Foundation

final class CollectionDetailViewModel {

    // MARK: - Properties

    var onNFTsUpdated: (() -> Void)?
    var onNFTLikeUpdated: ((Int, Bool) -> Void)?
    var onNFTCartUpdated: ((Int, Bool) -> Void)?
    var onLoadingStateChanged: ((Bool) -> Void)?
    var onError: ((String) -> Void)?
    var onCollectionLoaded: ((NftCollection) -> Void)?

    private(set) var nfts: [NFTCellModel] = []

    let collectionId: String

    private let collectionService: CollectionService
    private let nftService: NftService
    private let favoritesStorage: FavoritesStorage
    private let cartStorage: CartStorage

    // MARK: - Init

    init(
        collectionId: String,
        collectionService: CollectionService,
        nftService: NftService,
        favoritesStorage: FavoritesStorage = FavoritesStorageImpl.shared,
        cartStorage: CartStorage = CartStorageImpl.shared
    ) {
        self.collectionId = collectionId
        self.collectionService = collectionService
        self.nftService = nftService
        self.favoritesStorage = favoritesStorage
        self.cartStorage = cartStorage
    }

    // MARK: - Public Methods

    func viewDidLoad() {
        loadCollection()
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

        let nftId = nfts[index].id
        let newState = cartStorage.toggleCart(nftId: nftId)
        nfts[index].isInCart = newState

        onNFTCartUpdated?(index, newState)
    }

    // MARK: - Private Methods

    private func loadCollection() {
        onLoadingStateChanged?(true)

        collectionService.loadCollection(id: collectionId) { [weak self] result in
            guard let self = self else { return }

            switch result {
            case .success(let collection):
                self.onCollectionLoaded?(collection)
                self.loadNFTs(ids: collection.nfts)
            case .failure(let error):
                self.onLoadingStateChanged?(false)
                self.onError?(error.localizedDescription)
            }
        }
    }

    private func loadNFTs(ids: [String]) {
        let group = DispatchGroup()
        var loadedNFTs: [NFTCellModel] = []
        let lock = NSLock()

        for nftId in ids {
            group.enter()
            nftService.loadNft(id: nftId) { [weak self] result in
                guard let self = self else {
                    group.leave()
                    return
                }

                switch result {
                case .success(let nft):
                    let model = NFTCellModel(
                        id: nft.id,
                        name: nft.name,
                        imageURL: URL(string: nft.images.first ?? ""),
                        rating: nft.rating,
                        price: self.formatPrice(nft.price),
                        isLiked: self.favoritesStorage.isFavorite(nftId: nft.id),
                        isInCart: self.cartStorage.isInCart(nftId: nft.id)
                    )
                    lock.lock()
                    loadedNFTs.append(model)
                    lock.unlock()
                case .failure:
                    break
                }
                group.leave()
            }
        }

        group.notify(queue: .main) { [weak self] in
            guard let self = self else { return }
            self.nfts = loadedNFTs
            self.onLoadingStateChanged?(false)
            self.onNFTsUpdated?()
        }
    }

    private func formatPrice(_ price: Double) -> String {
        let formatted = price.truncatingRemainder(dividingBy: 1) == 0
            ? String(format: "%.0f", price)
            : String(format: "%.2f", price)
        return "\(formatted) ETH"
    }
}
