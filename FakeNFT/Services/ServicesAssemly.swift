import Foundation
import OSLog

final class ServicesAssembly {

    private let networkClient: NetworkClient
    private let nftStorage: NftStorage

    init(
        networkClient: NetworkClient,
        nftStorage: NftStorage
    ) {
        self.networkClient = networkClient
        self.nftStorage = nftStorage
    }

    var nftService: NftService {
        NftServiceImpl(
            networkClient: networkClient,
            storage: nftStorage
        )
    }

    var cartService: CartServiceProtocol {
        CartService(
            networkClient: networkClient,
            nftService: nftService
        )
    }
}

typealias CartItemsCompletion = (Result<[CartItem], Error>) -> Void
typealias CartItemsPartialUpdate = ([CartItem]) -> Void
typealias CartPlaceholdersUpdate = ([String]) -> Void

protocol CartServiceProtocol: AnyObject {
    func fetchCartItems(completion: @escaping CartItemsCompletion)
    func fetchCartItems(
        onPlaceholders: CartPlaceholdersUpdate?,
        onPartialUpdate: CartItemsPartialUpdate?,
        completion: @escaping CartItemsCompletion
    )
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
        Self.logger.info("[\(requestID, privacy: .public)] Starting cart order request: /api/v1/orders/1")

        networkClient.send(
            request: CartOrderRequest(),
            type: CartOrderResponse.self,
            completionQueue: responseQueue
        ) { [weak self] result in
            guard let self else { return }
            switch result {
            case .success(let order):
                let orderRequestDuration = Date().timeIntervalSince(startedAt)
                Self.logger.info("[\(requestID, privacy: .public)] Order response received. orderID=\(order.id, privacy: .public), idsCount=\(order.nfts.count), duration=\(orderRequestDuration, format: .fixed(precision: 3))s")
                let joinedIDs = order.nfts.joined(separator: ",")
                Self.logger.debug("[\(requestID, privacy: .public)] NFT IDs payload: \(joinedIDs, privacy: .public)")

                DispatchQueue.main.async {
                    Self.logger.debug("[\(requestID, privacy: .public)] Sending placeholders to UI. placeholdersCount=\(order.nfts.count)")
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
                let orderRequestDuration = Date().timeIntervalSince(startedAt)
                Self.logger.error("[\(requestID, privacy: .public)] Failed to load cart order after \(orderRequestDuration, format: .fixed(precision: 3))s. error=\(String(describing: error), privacy: .public)")
                DispatchQueue.main.async {
                    completion(.failure(error))
                }
            }
        }
    }
}

private extension CartService {
    func loadNfts(
        ids: [String],
        traceID: String,
        requestStartedAt: Date,
        onPartialUpdate: CartItemsPartialUpdate?,
        completion: @escaping CartItemsCompletion
    ) {
        guard !ids.isEmpty else {
            Self.logger.info("[\(traceID, privacy: .public)] Order contains no NFT IDs. Returning empty cart.")
            DispatchQueue.main.async {
                completion(.success([]))
            }
            return
        }

        Self.logger.info("[\(traceID, privacy: .public)] Starting NFT details loading for \(ids.count) IDs. batchSize=\(Self.progressBatchSize)")

        let lock = NSLock()
        let group = DispatchGroup()
        var firstError: Error?
        var itemsByID: [String: CartItem] = [:]
        var loadedCount = 0
        var lastEmittedCount = 0

        for id in ids {
            group.enter()
            Self.logger.debug("[\(traceID, privacy: .public)] Requesting NFT details by ID: \(id, privacy: .public)")
            nftService.loadNft(id: id) { result in
                defer { group.leave() }
                var partialItems: [CartItem]?

                lock.lock()
                switch result {
                case .success(let nft):
                    itemsByID[id] = self.mapNftToCartItem(nft)
                    loadedCount += 1
                    Self.logger.debug("[\(traceID, privacy: .public)] NFT loaded: id=\(id, privacy: .public), loadedCount=\(loadedCount)/\(ids.count)")

                    let shouldEmitProgress = loadedCount == 1 ||
                    loadedCount - lastEmittedCount >= Self.progressBatchSize
                    if shouldEmitProgress {
                        lastEmittedCount = loadedCount
                        partialItems = ids.compactMap { itemsByID[$0] }
                        Self.logger.debug("[\(traceID, privacy: .public)] Emitting partial update. emittedCount=\(partialItems?.count ?? 0), loadedCount=\(loadedCount)")
                    }
                case .failure(let error):
                    Self.logger.error("[\(traceID, privacy: .public)] Failed to load NFT by ID: \(id, privacy: .public). error=\(String(describing: error), privacy: .public)")
                    if firstError == nil {
                        firstError = error
                        Self.logger.error("[\(traceID, privacy: .public)] Captured first error for final completion.")
                    }
                }
                lock.unlock()

                if let partialItems {
                    DispatchQueue.main.async {
                        Self.logger.debug("[\(traceID, privacy: .public)] Delivering partial update to UI. itemsCount=\(partialItems.count)")
                        onPartialUpdate?(partialItems)
                    }
                }
            }
        }

        group.notify(queue: responseQueue) {
            if let firstError {
                let totalDuration = Date().timeIntervalSince(requestStartedAt)
                Self.logger.error("[\(traceID, privacy: .public)] Finishing with failure. loaded=\(itemsByID.count)/\(ids.count), duration=\(totalDuration, format: .fixed(precision: 3))s, error=\(String(describing: firstError), privacy: .public)")
                DispatchQueue.main.async {
                    completion(.failure(firstError))
                }
                return
            }

            let orderedItems = ids.compactMap { itemsByID[$0] }
            let totalDuration = Date().timeIntervalSince(requestStartedAt)
            Self.logger.info("[\(traceID, privacy: .public)] Completed cart load successfully. orderedItemsCount=\(orderedItems.count), duration=\(totalDuration, format: .fixed(precision: 3))s")
            DispatchQueue.main.async {
                completion(.success(orderedItems))
            }
        }
    }

    func mapNftToCartItem(_ nft: Nft) -> CartItem {
        Self.logger.debug("Mapping NFT to CartItem. id=\(nft.id, privacy: .public), name=\(nft.name, privacy: .public), rating=\(nft.rating), price=\(nft.price, format: .fixed(precision: 2))")
        return CartItem(
            id: nft.id,
            name: nft.name,
            images: nft.images,
            rating: nft.rating,
            price: nft.price
        )
    }
}
