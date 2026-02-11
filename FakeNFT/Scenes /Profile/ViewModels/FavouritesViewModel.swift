import Foundation

protocol FavouritesViewModelProtocol: AnyObject {
    var onStateChange: ((FavouritesState) -> Void)? { get set }
    var nftsUI: [FavouriteNftUI] { get }
    
    func loadNfts()
}

final class FavouritesViewModel: FavouritesViewModelProtocol {
    
    // MARK: - Bindings
    
    var onStateChange: ((FavouritesState) -> Void)?
    
    // MARK: - Public Properties
    
    private(set) var nftsUI: [FavouriteNftUI] = []
    
    // MARK: - Public Methods
    
    func loadNfts() {
        state = .loading
        loadLikedIds()
    }
    
    // MARK: - State
    
    private var state: FavouritesState = .initial {
        didSet {
            onStateChange?(state)
        }
    }
    
    // MARK: - Private Properties
    
    private let profileService: ProfileServiceProtocol
    private let nftService: ProfileNftByIdServiceProtocol
    
    private var favouriteNfs: [ProfileNft] = []
    private var idsToLoad: Set<UUID> = []
    
    private lazy var priceFormatter: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.minimumFractionDigits = 2
        formatter.maximumFractionDigits = 2
        return formatter
    }()
    
    init(
        servicesAssembly: ServicesAssembly,
    ) {
        self.profileService = servicesAssembly.profileService
        self.nftService = servicesAssembly.favouritesService
    }
    
    // MARK: - Private Methods
    
    private func mapToUI(_ nft: ProfileNft) -> FavouriteNftUI {
        FavouriteNftUI(
            name: nft.name,
            image: nft.images[safe: 0],
            rating: nft.rating,
            price: priceFormatter.string(from: nft.price as NSDecimalNumber) ?? "",
            id: nft.id,
            isLiked: idsToLoad.contains(nft.id)
        )
    }
    
    private func updateNftsUI() {
        let sorted = favouriteNfs.sorted { $0.createdAt > $1.createdAt }
        nftsUI = sorted.map { mapToUI($0) }
    }
    
    private func loadLikedIds() {
        profileService.loadProfile() { [weak self] result in
            switch result {
            case .success(let profile):
                self?.idsToLoad = Set(profile.likes)
                self?.loadLikedNfts()
                
            case .failure(let error):
                self?.state = .failed
                print("❌[ProfileService] failed to load data, error: \(error)")
            }
        }
    }
    
    private func loadLikedNfts() {
        nftService.loadNfts(withIds: Array(idsToLoad)) { [weak self] result in
            switch result {
            case .success(let nfts):
                self?.favouriteNfs = nfts
                self?.updateNftsUI()
                self?.state = .data
                
            case .failure(let error):
                self?.state = .failed
                print("❌[ProfileNftByIdService] failed to load data, error: \(error)")
            }
        }
    }
    
}
