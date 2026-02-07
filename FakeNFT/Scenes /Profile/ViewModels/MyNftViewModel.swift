import Foundation

final class MyNftViewModel: MyNftViewModelProtocol {
    
    // MARK: - Bindings
    
    var onStateChange: ((MyNftState) -> Void)?
    var onSortChange: (() -> Void)?
    var onLikesUpdate: (() -> Void)?
    
    // MARK: - Public Properties
    
    private(set) var sortedNfts: [MyNftUI] = []
    
    // MARK: - Public Methods
    
    // TODO: - Should be changed after service implementation
    func loadNfts() {
        state = .loading
        
        loadMockData()
        updateSortedNfts()
        state = .data
    }
    
    func changeSort(_ sort: SortOption) {
        self.sort = sort
    }
    
    func setLike(id: UUID) {
        if likedNfts.contains(id) {
            likedNfts.remove(id)
        } else {
            likedNfts.insert(id)
        }
    }
    
    // MARK: - State
    
    private var state: MyNftState = .initial {
        didSet {
            onStateChange?(state)
        }
    }
    
    // MARK: - Private Properties
    
    private let sortStorage: SortOptionStorageProtocol
    private var nfts: [ProfileNft] = []
    
    private var sort: SortOption {
        didSet {
            sortStorage.sortOption = sort
            updateSortedNfts()
            onSortChange?()
        }
    }
    
    private var likedNfts: Set<UUID> = [] {
        didSet {
            updateLikedNfts(likes: likedNfts)
        }
    }
    
    private lazy var priceFormatter: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.minimumFractionDigits = 2
        formatter.maximumFractionDigits = 2
        return formatter
    }()
    
    // MARK: - Init
    
    convenience init() {
        let sortStorage = SortOptionStorage()
        self .init(sortStorage: sortStorage)
    }
    
    init(sortStorage: SortOptionStorageProtocol) {
        self.sortStorage = sortStorage
        sort = sortStorage.sortOption
    }
    
    // MARK: - Private Methods
    
    private func mapToUI(_ nft: ProfileNft) -> MyNftUI {
        MyNftUI(
            name: nft.name,
            image: nft.images[safe: 0],
            rating: nft.rating,
            price: priceFormatter.string(from: nft.price as NSDecimalNumber) ?? "",
            author: nft.author,
            id: nft.id,
            isLiked: likedNfts.contains(nft.id)
        )
    }
    
    private func updateSortedNfts() {
        let sorted = sortNfts(nfts, by: sort)
        sortedNfts = sorted.map { mapToUI($0) }
    }
    
    private func sortNfts(_ nfts: [ProfileNft], by sort: SortOption) -> [ProfileNft] {
        switch sort {
        case .name:
            return nfts.sorted { $0.name.localizedCaseInsensitiveCompare($1.name) == .orderedAscending }
        case .price:
            return nfts.sorted { $0.price < $1.price }
        case .rating:
            return nfts.sorted { $0.rating > $1.rating }
        }
    }
    
    // TODO: - Should be changed after service implementation
    private func updateLikedNfts(likes: Set<UUID>) {
        print("Likes: \(likes.count)")
        updateSortedNfts()
        onLikesUpdate?()
    }
    
    // TODO: - Should be deleted after service implementation
    // NOTE: Force unwrap is used only for test purposes
    private func loadMockData() {
        nfts = [
            ProfileNft(
                createdAt: Date(),
                name: "commodo porttitor",
                images: [
                    URL(string: "https://code.s3.yandex.net/Mobile/iOS/NFT/Beige/April/1.png")!,
                    URL(string: "https://code.s3.yandex.net/Mobile/iOS/NFT/Beige/April/2.png")!,
                    URL(string: "https://code.s3.yandex.net/Mobile/iOS/NFT/Beige/April/3.png")!
                ],
                rating: 3,
                description: "fringilla eam vim sonet faucibus impetus",
                price: 36.54,
                author: "Condescending Almeida",
                website: URL(string: "https://condescending_almeida.fakenfts.org/")!,
                id: UUID(uuidString: "739e293c-1067-43e5-8f1d-4377e744ddde")!
            ),
            ProfileNft(
                createdAt: Date(),
                name: "dico eleifend",
                images: [
                    URL(string: "https://code.s3.yandex.net/Mobile/iOS/NFT/Yellow/Helga/1.png")!,
                    URL(string: "https://code.s3.yandex.net/Mobile/iOS/NFT/Yellow/Helga/2.png")!,
                    URL(string: "https://code.s3.yandex.net/Mobile/iOS/NFT/Yellow/Helga/3.png")!,
                ],
                rating: 5,
                description: "tritani appareat constituam deterruisset justo",
                price: 8.08,
                author: "Quizzical Blackwell",
                website: URL(string: "https://quizzical_blackwell.fakenfts.org/")!,
                id: UUID(uuidString: "1464520d-1659-4055-8a79-4593b9569e48")!
            ),
            ProfileNft(
                createdAt: Date(),
                name: "eleifend mutat",
                images: [
                    URL(string: "https://code.s3.yandex.net/Mobile/iOS/NFT/Gray/Kaydan/1.png")!,
                    URL(string: "https://code.s3.yandex.net/Mobile/iOS/NFT/Gray/Kaydan/2.png")!,
                    URL(string: "https://code.s3.yandex.net/Mobile/iOS/NFT/Gray/Kaydan/3.png")!,
                ],
                rating: 2,
                description: "tacimates docendi efficitur tempus non quod cras pellentesque commune",
                price: 16.95,
                author: "Goofy Napier",
                website: URL(string: "https://goofy_napier.fakenfts.org/")!,
                id: UUID(uuidString: "5093c01d-e79e-4281-96f1-76db5880ba70")!
            )
        ]
    }
    
}
