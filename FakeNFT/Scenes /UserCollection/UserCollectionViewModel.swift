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
    private let cartStorage: CartStorage

    private var profile: Profile?

    init(
        userId: String,
        userService: UserServiceProtocol,
        nftService: NftService,
        profileService: ProfileServiceProtocol,
        likesStorage: LikesStoring = LikesStorage(),
        cartStorage: CartStorage = CartStorageImpl.shared
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
        var profileResult: Result<Profile, Error>?

        group.enter()
        userService.fetchUser(id: userId) { result in
            userResult = result
            group.leave()
        }

        group.enter()
        profileService.loadProfile { result in
            profileResult = result
            group.leave()
        }

        group.notify(queue: .main) { [weak self] in
            guard let self else { return }

            switch (userResult, profileResult) {
            case (.success(let user), .success(let profile)):
                self.profile = profile

                // Серверные лайки (UUID) -> строки
                let serverLikes: Set<String> = Set(profile.likes.map { $0.uuidString.lowercased() })

                // Локальные лайки уже строками
                let localLikes = self.likesStorage.allLikedIds().map { $0.lowercased() }
                let mergedLikes = serverLikes.union(localLikes)

                // Сохраняем мердж в локальное хранилище
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
        guard items.indices.contains(index), let profile else { return }

        var item = items[index]
        item.isLiked.toggle()
        items[index] = item

        let id = item.id.lowercased()

        likesStorage.setLiked(item.isLiked, id: id)
        onItemsChanged?()

        // Берём актуальные лайки из локального стораджа
        let likedIds = likesStorage.allLikedIds().map { $0.lowercased() }

        // Конвертим строки в UUID (в API профиля лайки — UUID)
        let uuids: [UUID] = likedIds.compactMap { UUID(uuidString: $0) }

        let dto = ProfileLikesDto(likes: uuids)

        profileService.updateProfileLikes(with: dto) { [weak self] result in
            guard let self else { return }

            switch result {
            case .success(let newProfile):
                self.profile = newProfile

                // Серверные -> строки
                let serverLikes = Set(newProfile.likes.map { $0.uuidString.lowercased() })

                // Мердж серверных и локальных (чтобы ничего не потерять)
                let merged = self.likesStorage
                    .allLikedIds()
                    .map { $0.lowercased() }

                self.likesStorage.setAllLikedIds(serverLikes.union(merged))

            case .failure(let error):
                // (по желанию) откатить UI если нужно, но чаще достаточно показать ошибку
                self.onError?(error.localizedDescription)
            }
        }
    }

    func toggleCart(at index: Int) {
        guard items.indices.contains(index) else { return }

        let id = items[index].id

        // CartStorageImpl сам решает, добавить или убрать, и возвращает новое состояние
        let newInCart = cartStorage.toggleCart(nftId: id)

        items[index].isInCart = newInCart
        onItemsChanged?()
    }

    private func loadNfts(ids: [String], likedIds: Set<String>) {
        let group = DispatchGroup()

        // чтобы не было гонок данных при параллельных callbacks
        let lockQueue = DispatchQueue(label: "com.fakenft.usercollection.lock")

        var loaded: [Nft] = []
        var firstError: Error?

        for id in ids {
            group.enter()
            nftService.loadNft(id: id) { result in
                lockQueue.async {
                    switch result {
                    case .success(let nft):
                        loaded.append(nft)
                    case .failure(let error):
                        if firstError == nil { firstError = error }
                    }
                    group.leave()
                }
            }
        }

        group.notify(queue: .main) { [weak self] in
            guard let self else { return }
            self.onLoadingChanged?(false)

            if let firstError {
                self.onError?(firstError.localizedDescription)
                return
            }

            // упорядочиваем так же, как ids
            let byId = Dictionary(uniqueKeysWithValues: loaded.map { ($0.id, $0) })
            let ordered = ids.compactMap { byId[$0] }

            self.items = ordered.map { nft in
                // В FakeNFT чаще всего Nft.images: [String]
                let imageURL: URL? = {
                    guard let first = nft.images.first else { return nil }
                    return URL(string: first)
                }()

                let nftId = nft.id.lowercased()

                return UserCollectionItemViewModel(
                    id: nft.id,
                    imageURL: imageURL,
                    name: nft.name,
                    priceText: String(format: "%.2f ETH", nft.price),
                    rating: nft.rating,
                    isLiked: likedIds.contains(nftId),
                    isInCart: self.cartStorage.isInCart(nftId: nft.id)
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

