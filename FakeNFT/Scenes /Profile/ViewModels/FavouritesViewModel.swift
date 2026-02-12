import Foundation

final class FavouritesViewModel: FavouritesViewModelProtocol {
    
    // MARK: - Bindings
    
    var onStateChange: ((FavouritesState) -> Void)?
    var onLikesUpdate: (() -> Void)?
    
    // MARK: - Public Properties
    
    private(set) var nftsUI: [FavouriteNftUI] = []
    
    // MARK: - Public Methods
    
    func loadNfts() {
        state = .loading
        loadLikedIds()
    }
    
    func setLike(id: UUID) {
        let oldIds = likedIds
        let oldNfts = favouriteNfts
        
        let isRemoving = likedIds.contains(id)
        likedIds.formSymmetricDifference([id])
        
        if isRemoving {
            favouriteNfts.removeAll { $0.id == id }
        }
        
        updateNftsUI()
        onLikesUpdate?()
        
        let likesDto = ProfileLikesDto(likes: Array(likedIds))
        updateLikes(
            dto: likesDto,
            oldIds: oldIds,
            oldNfts: oldNfts
        )
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
    
    private var favouriteNfts: [ProfileNft] = []
    private var likedIds: Set<UUID> = []
    
    private lazy var priceFormatter: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.minimumFractionDigits = 2
        formatter.maximumFractionDigits = 2
        return formatter
    }()
    
    // MARK: - Init
    
    init(
        profileService: ProfileServiceProtocol,
        favouritesService: ProfileNftByIdServiceProtocol
    ) {
        self.profileService = profileService
        self.nftService = favouritesService
    }
    
    // MARK: - Private Methods
    
    private func mapToUI(_ nft: ProfileNft) -> FavouriteNftUI {
        FavouriteNftUI(
            name: nft.name,
            image: nft.images[safe: 0],
            rating: nft.rating,
            price: priceFormatter.string(from: nft.price as NSDecimalNumber) ?? "",
            id: nft.id
        )
    }
    
    private func updateNftsUI() {
        let sorted = favouriteNfts.sorted { $0.createdAt > $1.createdAt }
        nftsUI = sorted.map { mapToUI($0) }
    }
    
    private func loadLikedIds() {
        profileService.loadProfile() { [weak self] result in
            switch result {
            case .success(let profile):
                self?.likedIds = Set(profile.likes)
                self?.loadLikedNfts()
                
            case .failure(let error):
                self?.state = .failed
                print("❌[ProfileService] failed to load data, error: \(error)")
            }
        }
    }
    
    private func loadLikedNfts() {
        nftService.loadNfts(withIds: Array(likedIds)) { [weak self] result in
            switch result {
            case .success(let nfts):
                self?.favouriteNfts = nfts
                self?.updateNftsUI()
                self?.state = .data
                
            case .failure(let error):
                self?.state = .failed
                print("❌[ProfileNftByIdService] failed to load data, error: \(error)")
            }
        }
    }
    
    private func updateLikes(
        dto: ProfileLikesDto,
        oldIds: Set<UUID>,
        oldNfts: [ProfileNft]
    ) {
        profileService.updateProfileLikes(with: dto) { [weak self] result in
            switch result {
            case .success(let profile):
                let serverLikes = Set(profile.likes)
                if serverLikes != self?.likedIds {
                    self?.likedIds = serverLikes
                    self?.reloadOnLikesUpdate()
                }
                
            case .failure(let error):
                self?.likedIds = oldIds
                self?.favouriteNfts = oldNfts
                self?.updateNftsUI()
                self?.onLikesUpdate?()
                print("❌[ProfileService] failed to update likes, error: \(error)")
            }
        }
    }
    
    private func reloadOnLikesUpdate() {
        nftService.loadNfts(withIds: Array(likedIds)) { [weak self] result in
            switch result {
            case .success(let nfts):
                self?.favouriteNfts = nfts
                self?.updateNftsUI()
                self?.onLikesUpdate?()
                
            case .failure(let error):
                print("❌[ProfileNftByIdService] failed to load data, error: \(error)")
            }
        }
    }
    
}
