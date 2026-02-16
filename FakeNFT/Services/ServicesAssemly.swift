import Foundation
import OSLog

final class ServicesAssembly {

    private let networkClient: NetworkClient
    private let nftStorage: NftStorage

    private let collectionStorage: CollectionStorage

    private let profileStorage: ProfileStorageProtocol
    private let myNftStorage: ProfileNftStorageProtocol
    private let favouritesStorage: ProfileNftStorageProtocol

    init(
        networkClient: NetworkClient,
        nftStorage: NftStorage,
        collectionStorage: CollectionStorage = CollectionStorageImpl(),
        profileStorage: ProfileStorageProtocol,
        myNftStorage: ProfileNftStorageProtocol,
        favouritesStorage: ProfileNftStorageProtocol
    ) {
        self.networkClient = networkClient
        self.nftStorage = nftStorage
        self.collectionStorage = collectionStorage
        self.profileStorage = profileStorage
        self.myNftStorage = myNftStorage
        self.favouritesStorage = favouritesStorage
    }

    var nftService: NftService {
        NftServiceImpl(
            networkClient: networkClient,
            storage: nftStorage
        )
    }

    var collectionService: CollectionService {
        CollectionServiceImpl(
            networkClient: networkClient,
            storage: collectionStorage
        )
    }

    var profileService: ProfileServiceProtocol {
        ProfileService(
            networkClient: networkClient,
            storage: profileStorage
        )
    }

    var myNftService: ProfileNftByIdServiceProtocol {
        ProfileNftByIdService(
            networkClient: networkClient,
            storage: myNftStorage
        )
    }

    var favouritesService: ProfileNftByIdServiceProtocol {
        ProfileNftByIdService(
            networkClient: networkClient,
            storage: favouritesStorage
        )
    }

    var cartService: CartServiceProtocol {
        CartService(
            networkClient: networkClient,
            nftService: nftService
        )
    }

    // ✅ ДОБАВЛЯЕМ ЗДЕСЬ (а не в CartService)
    var statisticsService: StatisticsServiceProtocol {
        StatisticsService(client: networkClient)
    }

    var userService: UserServiceProtocol {
        UserService(client: networkClient)
    }
}

typealias CartItemsCompletion = (Result<[CartItem], Error>) -> Void
typealias CartItemsPartialUpdate = ([CartItem]) -> Void
typealias CartPlaceholdersUpdate = ([String]) -> Void
typealias CartMutationCompletion = (Result<[String], Error>) -> Void

protocol CartServiceProtocol: AnyObject {
    func fetchCartItems(completion: @escaping CartItemsCompletion)

    func fetchCartItems(
        onPlaceholders: CartPlaceholdersUpdate?,
        onPartialUpdate: CartItemsPartialUpdate?,
        completion: @escaping CartItemsCompletion
    )

    func addCartItem(id: String, completion: @escaping CartMutationCompletion)
    func removeCartItem(id: String, completion: @escaping CartMutationCompletion)
}

extension CartServiceProtocol {
    func fetchCartItems(completion: @escaping CartItemsCompletion) {
        fetchCartItems(
            onPlaceholders: nil,
            onPartialUpdate: nil,
            completion: completion
        )
    }
}

final class CartService: CartServiceProtocol {

    private static let logger = Logger(subsystem: "com.fakenft.app", category: "CartService")
    private static let progressBatchSize = 3

    private let networkClient: NetworkClient
    private let nftService: NftService
    private let responseQueue = DispatchQueue(label: "com.fakenft.cartservice.response", qos: .userInitiated)

    init(
        networkClient: NetworkClient = DefaultNetworkClient(),
        nftStorage: NftStorage = NftStorageImpl()
    ) {
        self.networkClient = networkClient
        self.nftService = NftServiceImpl(networkClient: networkClient, storage: nftStorage)
    }

    init(networkClient: NetworkClient, nftService: NftService) {
        self.networkClient = networkClient
        self.nftService = nftService
    }

    func fetchCartItems(
        onPlaceholders: CartPlaceholdersUpdate?,
        onPartialUpdate: CartItemsPartialUpdate?,
        completion: @escaping CartItemsCompletion
    ) {
        let requestID = UUID().uuidString
        let startedAt = Date()

        networkClient.send(
            request: CartOrderRequest(),
            type: CartOrderResponse.self,
            completionQueue: responseQueue
        ) { [weak self] result in
            guard let self else { return }

            switch result {
            case .success(let order):
                DispatchQueue.main.async {
                    onPlaceholders?(order.nfts)
                }

                self.loadNfts(
                    ids: order.nfts,
                    traceID: requestID,
                    requestStartedAt: startedAt,
                    onPartialUpdate: onPartialUpdate,
                    completion: completion
                )

            case .failure(let error):
                DispatchQueue.main.async {
                    completion(.failure(error))
                }
            }
        }
    }

    func addCartItem(id: String, completion: @escaping CartMutationCompletion) {
        mutateOrder(id: id, action: .add, completion: completion)
    }

    func removeCartItem(id: String, completion: @escaping CartMutationCompletion) {
        mutateOrder(id: id, action: .remove, completion: completion)
    }
}

private extension CartService {

    enum CartMutationAction: String {
        case add
        case remove
    }

    func mutateOrder(
        id: String,
        action: CartMutationAction,
        completion: @escaping CartMutationCompletion
    ) {
        networkClient.send(
            request: CartOrderRequest(),
            type: CartOrderResponse.self,
            completionQueue: responseQueue
        ) { [weak self] result in
            guard let self else { return }

            switch result {
            case .success(let order):
                let updatedIDs: [String]
                switch action {
                case .add:
                    updatedIDs = order.nfts.contains(id) ? order.nfts : order.nfts + [id]
                case .remove:
                    updatedIDs = order.nfts.filter { $0 != id }
                }

                if updatedIDs == order.nfts {
                    DispatchQueue.main.async {
                        completion(.success(order.nfts))
                    }
                    return
                }

                self.sendOrderUpdate(nftIDs: updatedIDs, completion: completion)

            case .failure(let error):
                DispatchQueue.main.async {
                    completion(.failure(error))
                }
            }
        }
    }

    func sendOrderUpdate(
        nftIDs: [String],
        completion: @escaping CartMutationCompletion
    ) {
        networkClient.send(
            request: UpdateCartOrderRequest(nftIDs: nftIDs),
            type: CartOrderResponse.self,
            completionQueue: responseQueue
        ) { result in
            DispatchQueue.main.async {
                switch result {
                case .success(let response):
                    completion(.success(response.nfts))
                case .failure(let error):
                    completion(.failure(error))
                }
            }
        }
    }

    func loadNfts(
        ids: [String],
        traceID: String,
        requestStartedAt: Date,
        onPartialUpdate: CartItemsPartialUpdate?,
        completion: @escaping CartItemsCompletion
    ) {
        guard !ids.isEmpty else {
            DispatchQueue.main.async { completion(.success([])) }
            return
        }

        let lock = NSLock()
        let group = DispatchGroup()
        var firstError: Error?
        var itemsByID: [String: CartItem] = [:]
        var loadedCount = 0
        var lastEmittedCount = 0

        for id in ids {
            group.enter()
            nftService.loadNft(id: id) { result in
                defer { group.leave() }
                var partialItems: [CartItem]?

                lock.lock()
                switch result {
                case .success(let nft):
                    itemsByID[id] = CartItem(
                        id: nft.id,
                        name: nft.name,
                        images: nft.images,
                        rating: nft.rating,
                        price: nft.price
                    )
                    loadedCount += 1

                    let shouldEmit = loadedCount == 1 || loadedCount - lastEmittedCount >= Self.progressBatchSize
                    if shouldEmit {
                        lastEmittedCount = loadedCount
                        partialItems = ids.compactMap { itemsByID[$0] }
                    }

                case .failure(let error):
                    if firstError == nil { firstError = error }
                }
                lock.unlock()

                if let partialItems {
                    DispatchQueue.main.async {
                        onPartialUpdate?(partialItems)
                    }
                }
            }
        }

        group.notify(queue: responseQueue) {
            if let firstError {
                DispatchQueue.main.async { completion(.failure(firstError)) }
                return
            }
            let orderedItems = ids.compactMap { itemsByID[$0] }
            DispatchQueue.main.async { completion(.success(orderedItems)) }
        }
    }
}

