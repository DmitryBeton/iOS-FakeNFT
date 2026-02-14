import Foundation

final class MyNftViewModel: MyNftViewModelProtocol {
    
    // MARK: - Bindings
    
    var onStateChange: ((MyNftState) -> Void)?
    var onSortChange: (() -> Void)?
    var onLikesUpdate: (() -> Void)?
    
    // MARK: - Public Properties
    
    private(set) var sortedNfts: [MyNftUI] = []
    
    // MARK: - Public Methods
    
    func loadNfts() {
        state = .loading
        loadProfileData()
    }
    
    func changeSort(_ sort: SortOption) {
        self.sort = sort
    }
    
    func setLike(id: UUID) {
        let oldValue = likedNfts
        likedNfts.formSymmetricDifference([id])
        
        updateSortedNfts()
        onLikesUpdate?()
        
        let likesDto = ProfileLikesDto(likes: Array(likedNfts))
        updateLikes(dto: likesDto, oldValue: oldValue)
    }
    
    // MARK: - State
    
    private var state: MyNftState = .initial {
        didSet {
            onStateChange?(state)
        }
    }
    
    // MARK: - Private Properties
    
    private let profileService: ProfileServiceProtocol
    private let nftService: ProfileNftByIdServiceProtocol
    private let sortStorage: SortOptionStorageProtocol
    
    private var nfts: [ProfileNft] = []
    private var likedNfts: Set<UUID> = []
    
    private var sort: SortOption {
        didSet {
            sortStorage.sortOption = sort
            updateSortedNfts()
            onSortChange?()
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
    
    convenience init(
        profileService: ProfileServiceProtocol,
        myNftService: ProfileNftByIdServiceProtocol
    ) {
        let sortStorage = SortOptionStorage()
        self .init(
            profileService: profileService,
            myNftService: myNftService,
            sortStorage: sortStorage
        )
    }
    
    init(
        profileService: ProfileServiceProtocol,
        myNftService: ProfileNftByIdServiceProtocol,
        sortStorage: SortOptionStorageProtocol
    ) {
        self.profileService = profileService
        self.nftService = myNftService
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
        nfts.sorted { lhs, rhs in
            switch sort {
            case .name:
                let comparison = lhs.name.localizedCaseInsensitiveCompare(rhs.name)
                if comparison != .orderedSame {
                    return comparison == .orderedAscending
                }
            case .price:
                if lhs.price != rhs.price {
                    return lhs.price < rhs.price
                }
            case .rating:
                if lhs.rating != rhs.rating {
                    return lhs.rating > rhs.rating
                }
            }
            
            return lhs.createdAt > rhs.createdAt
        }
    }
    
    private func loadProfileData() {
        profileService.loadProfile() { [weak self] result in
            switch result {
            case .success(let profileResult):
                self?.likedNfts = Set(profileResult.likes)
                let idsToLoad = profileResult.nfts
                self?.fetchProfileNfts(ids: idsToLoad)
                
            case .failure(let profileError):
                self?.state = .failed
                print("❌[ProfileService] failed to load data, error: \(profileError)")
            }
        }
    }
    
    private func fetchProfileNfts(ids: [UUID]) {
        nftService.loadNfts(withIds: ids) { [weak self] result in
            switch result {
            case .success(let nfts):
                self?.nfts = nfts
                self?.updateSortedNfts()
                self?.state = .data
                
            case .failure(let error):
                self?.state = .failed
                print("❌[ProfileNftByIdService] failed to load data, error: \(error)")
            }
        }
    }
    
    private func updateLikes(dto: ProfileLikesDto, oldValue: Set<UUID>) {
        profileService.updateProfileLikes(with: dto) { [weak self] result in
            switch result {
            case .success(let profile):
                let serverLikes = Set(profile.likes)
                guard serverLikes != self?.likedNfts else { return }
                self?.likedNfts = Set(profile.likes)
                
            case .failure(let error):
                self?.likedNfts = oldValue
                print("❌[ProfileService] failed to update likes, error: \(error)")
            }
            self?.updateSortedNfts()
            self?.onLikesUpdate?()
        }
    }
    
}
