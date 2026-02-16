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
    private let cartService: CartServiceProtocol
    private let favoritesStorage: FavoritesStorage
    private let cartStorage: CartStorage
    private var pendingCartMutations: Set<String> = []

    // MARK: - Init

    init(
        collectionId: String,
        collectionService: CollectionService,
        nftService: NftService,
        cartService: CartServiceProtocol,
        favoritesStorage: FavoritesStorage = FavoritesStorageImpl.shared,
        cartStorage: CartStorage = CartStorageImpl.shared
    ) {
        self.collectionId = collectionId
        self.collectionService = collectionService
        self.nftService = nftService
        self.cartService = cartService
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
        guard !pendingCartMutations.contains(nftId) else { return }

        let previousState = nfts[index].isInCart
        let targetState = !previousState

        pendingCartMutations.insert(nftId)
        nfts[index].isInCart = targetState
        onNFTCartUpdated?(index, targetState)

        let completion: (Result<[String], Error>) -> Void = { [weak self] result in
            guard let self else { return }
            self.pendingCartMutations.remove(nftId)

            switch result {
            case .success(let ids):
                self.syncLocalCart(with: ids)
                if let refreshedIndex = self.nfts.firstIndex(where: { $0.id == nftId }) {
                    let actualState = ids.contains(nftId)
                    self.nfts[refreshedIndex].isInCart = actualState
                    self.onNFTCartUpdated?(refreshedIndex, actualState)
                }
                NotificationCenter.default.post(name: .cartDidChange, object: nil)
            case .failure:
                if let refreshedIndex = self.nfts.firstIndex(where: { $0.id == nftId }) {
                    self.nfts[refreshedIndex].isInCart = previousState
                    self.onNFTCartUpdated?(refreshedIndex, previousState)
                }
            }
        }

        if targetState {
            cartService.addCartItem(id: nftId, completion: completion)
        } else {
            cartService.removeCartItem(id: nftId, completion: completion)
        }
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

    private func syncLocalCart(with serverIDs: [String]) {
        let serverSet = Set(serverIDs)
        let localSet = Set(cartStorage.getAllCartItems())

        let toAdd = serverSet.subtracting(localSet)
        let toRemove = localSet.subtracting(serverSet)

        toAdd.forEach { cartStorage.addToCart(nftId: $0) }
        toRemove.forEach { cartStorage.removeFromCart(nftId: $0) }
    }
}
