import Foundation

struct UserCollectionItemViewModel {
    let id: String
    let imageURL: URL?
    let name: String
    let priceText: String
    let rating: Int
    var isLiked: Bool
    var isInCart: Bool
}

final class UserCollectionViewModel {

    var onLoadingChanged: ((Bool) -> Void)?
    var onItemsChanged: (() -> Void)?
    var onError: ((String) -> Void)?

    private(set) var items: [UserCollectionItemViewModel] = []

    private let userId: String
    private let userService: UserServiceProtocol
    private let nftService: NftService
    private let profileService: ProfileServiceProtocol
    private let likesStorage: LikesStoring
    private let cartStorage: CartStoring

    private var profile: ProfileDTO?

    init(
        userId: String,
        userService: UserServiceProtocol,
        nftService: NftService,
        profileService: ProfileServiceProtocol,
        likesStorage: LikesStoring = LikesStorage(),
        cartStorage: CartStoring = CartStorage.shared
    ) {
        self.userId = userId
        self.userService = userService
        self.nftService = nftService
        self.profileService = profileService
        self.likesStorage = likesStorage
        self.cartStorage = cartStorage
    }

    func load() {
        onLoadingChanged?(true)

        let group = DispatchGroup()

        var userResult: Result<UserDetailDTO, Error>?
        var profileResult: Result<ProfileDTO, Error>?

        group.enter()
        userService.fetchUser(id: userId) { result in
            userResult = result
            group.leave()
        }

        group.enter()
        profileService.fetchProfile { result in
            profileResult = result
            group.leave()
        }

        group.notify(queue: .global()) { [weak self] in
            guard let self else { return }

            switch (userResult, profileResult) {
            case (.success(let user), .success(let profile)):
                self.profile = profile

                let localLikes = self.likesStorage.allLikedIds()
                let mergedLikes = Set(profile.likes).union(localLikes)

                self.likesStorage.setAllLikedIds(mergedLikes)

                self.loadNfts(ids: user.nfts, likedIds: mergedLikes)

            case (.failure(let error), _):
                self.finishWithError(error)
            case (_, .failure(let error)):
                self.finishWithError(error)
            default:
                self.finishWithError(NSError(domain: "UserCollection", code: -1))
            }
        }
    }

    func toggleLike(at index: Int) {
        guard items.indices.contains(index), var profile else { return }

        var item = items[index]
        item.isLiked.toggle()
        items[index] = item

        likesStorage.setLiked(item.isLiked, id: item.id)

        onItemsChanged?()

        var likes = Set(profile.likes)
        if item.isLiked {
            likes.insert(item.id)
        } else {
            likes.remove(item.id)
        }

        let dto = UpdateProfileDto(
            name: profile.name,
            avatar: profile.avatar,
            description: profile.description,
            website: profile.website,
            likes: Array(likes)
        )

        profileService.updateProfile(dto: dto) { [weak self] result in
            guard let self else { return }
            if case .success(let newProfile) = result {
                self.profile = newProfile

                let merged = self.likesStorage.allLikedIds().union(Set(newProfile.likes))
                self.likesStorage.setAllLikedIds(merged)
            }
        }
    }
    
    func toggleCart(at index: Int) {
        guard items.indices.contains(index) else { return }

        var item = items[index]
        item.isInCart.toggle()
        items[index] = item

        cartStorage.setInCart(item.isInCart, id: item.id)

        onItemsChanged?()
    }

    private func loadNfts(ids: [String], likedIds: Set<String>) {
        let group = DispatchGroup()
        var loaded: [Nft] = []
        var anyError: Error?

        for id in ids {
            group.enter()
            nftService.loadNft(id: id) { result in
                switch result {
                case .success(let nft):
                    loaded.append(nft)
                case .failure(let error):
                    anyError = error
                }
                group.leave()
            }
        }

        group.notify(queue: .main) { [weak self] in
            guard let self else { return }
            self.onLoadingChanged?(false)

            if let anyError {
                self.onError?(anyError.localizedDescription)
                return
            }

            let byId = Dictionary(uniqueKeysWithValues: loaded.map { ($0.id, $0) })
            let ordered = ids.compactMap { byId[$0] }

            self.items = ordered.map { nft in
                UserCollectionItemViewModel(
                    id: nft.id,
                    imageURL: nft.images.first,
                    name: nft.name,
                    priceText: String(format: "%.2f ETH", nft.price),
                    rating: nft.rating,
                    isLiked: likedIds.contains(nft.id),
                    isInCart: self.cartStorage.isInCart(id: nft.id)
                )
            }

            self.onItemsChanged?()
        }
    }

    private func finishWithError(_ error: Error) {
        DispatchQueue.main.async { [weak self] in
            self?.onLoadingChanged?(false)
            self?.onError?(error.localizedDescription)
        }
    }
}

