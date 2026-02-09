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
    private static let orderCacheTTL: TimeInterval = 15

    private let networkClient: NetworkClient
    private let nftService: NftService
    private let responseQueue = DispatchQueue(label: "com.fakenft.cartservice.response", qos: .userInitiated)
    private let cacheQueue = DispatchQueue(label: "com.fakenft.cartservice.cache")
    private var cachedOrder: CartOrderResponse?
    private var orderCacheTimestamp: Date?
    private var cartDidChangeObserver: NSObjectProtocol?

    init(
        networkClient: NetworkClient = DefaultNetworkClient(),
        nftStorage: NftStorage = NftStorageImpl()
    ) {
        self.networkClient = networkClient
        self.nftService = NftServiceImpl(networkClient: networkClient, storage: nftStorage)
        subscribeToCartChanges()
    }

    init(networkClient: NetworkClient, nftService: NftService) {
        self.networkClient = networkClient
        self.nftService = nftService
        subscribeToCartChanges()
    }

    deinit {
        if let observer = cartDidChangeObserver {
            NotificationCenter.default.removeObserver(observer)
        }
    }

    func fetchCartItems(
        onPlaceholders: CartPlaceholdersUpdate?,
        onPartialUpdate: CartItemsPartialUpdate?,
        completion: @escaping CartItemsCompletion
    ) {
        let requestID = UUID().uuidString
        let startedAt = Date()
        if let cachedOrder = cachedOrderIfValid() {
            Self.logger.info("[\(requestID, privacy: .public)] Returning cached order. orderID=\(cachedOrder.id, privacy: .public), idsCount=\(cachedOrder.nfts.count)")
            DispatchQueue.main.async {
                Self.logger.debug("[\(requestID, privacy: .public)] Sending placeholders to UI. placeholdersCount=\(cachedOrder.nfts.count)")
                onPlaceholders?(cachedOrder.nfts)
            }
            loadNfts(
                ids: cachedOrder.nfts,
                traceID: requestID,
                requestStartedAt: startedAt,
                onPartialUpdate: onPartialUpdate,
                completion: completion
            )
            return
        }

        Self.logger.info("[\(requestID, privacy: .public)] Starting cart order request: /api/v1/orders/1")

        networkClient.send(
            request: CartOrderRequest(),
            type: CartOrderResponse.self,
            onTaskMetrics: { metrics in
                self.logOrderRequestMetrics(metrics, traceID: requestID)
            },
            completionQueue: responseQueue
        ) { [weak self] result in
            guard let self else { return }
            switch result {
            case .success(let order):
                self.storeOrderInCache(order)
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
        let traceID = UUID().uuidString
        Self.logger.info("[\(traceID, privacy: .public)] Starting cart mutation. action=\(action.rawValue, privacy: .public), nftID=\(id, privacy: .public)")

        networkClient.send(
            request: CartOrderRequest(),
            type: CartOrderResponse.self,
            completionQueue: responseQueue
        ) { [weak self] result in
            guard let self else { return }

            switch result {
            case .success(let order):
                self.storeOrderInCache(order)
                let updatedIDs: [String]
                switch action {
                case .add:
                    updatedIDs = order.nfts.contains(id) ? order.nfts : order.nfts + [id]
                case .remove:
                    updatedIDs = order.nfts.filter { $0 != id }
                }

                if updatedIDs == order.nfts {
                    Self.logger.info("[\(traceID, privacy: .public)] Cart mutation produced no changes. Returning current IDs.")
                    DispatchQueue.main.async {
                        completion(.success(order.nfts))
                    }
                    return
                }

                Self.logger.debug("[\(traceID, privacy: .public)] Sending PUT /api/v1/orders/1 with idsCount=\(updatedIDs.count)")
                self.sendOrderUpdate(nftIDs: updatedIDs, traceID: traceID, completion: completion)

            case .failure(let error):
                Self.logger.error("[\(traceID, privacy: .public)] Failed to load order before mutation. error=\(String(describing: error), privacy: .public)")
                DispatchQueue.main.async {
                    completion(.failure(error))
                }
            }
        }
    }

    func sendOrderUpdate(
        nftIDs: [String],
        traceID: String,
        completion: @escaping CartMutationCompletion
    ) {
        guard let url = URL(string: "\(RequestConstants.baseURL)/api/v1/orders/1") else {
            DispatchQueue.main.async {
                completion(.failure(NetworkClientError.urlSessionError))
            }
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = HttpMethod.put.rawValue
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        request.setValue(RequestConstants.token, forHTTPHeaderField: "X-Practicum-Mobile-Token")

        let body = nftIDs
            .map { "nfts=\($0.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? $0)" }
            .joined(separator: "&")
        request.httpBody = body.data(using: .utf8)

        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error {
                Self.logger.error("[\(traceID, privacy: .public)] PUT order failed with transport error: \(error.localizedDescription, privacy: .public)")
                DispatchQueue.main.async {
                    completion(.failure(NetworkClientError.urlRequestError(error)))
                }
                return
            }

            guard let http = response as? HTTPURLResponse else {
                DispatchQueue.main.async {
                    completion(.failure(NetworkClientError.urlSessionError))
                }
                return
            }

            guard 200 ..< 300 ~= http.statusCode else {
                let body = data.flatMap { String(data: $0, encoding: .utf8) } ?? "no-body"
                Self.logger.error("[\(traceID, privacy: .public)] PUT order failed. status=\(http.statusCode), body=\(body, privacy: .public)")
                DispatchQueue.main.async {
                    completion(.failure(NetworkClientError.httpStatusCode(http.statusCode)))
                }
                return
            }

            guard let data else {
                DispatchQueue.main.async {
                    completion(.failure(NetworkClientError.urlSessionError))
                }
                return
            }

            do {
                let response = try JSONDecoder().decode(CartOrderResponse.self, from: data)
                self.storeOrderInCache(response)
                Self.logger.info("[\(traceID, privacy: .public)] PUT order succeeded. idsCount=\(response.nfts.count)")
                DispatchQueue.main.async {
                    completion(.success(response.nfts))
                }
            } catch {
                Self.logger.error("[\(traceID, privacy: .public)] PUT order response parsing failed: \(error.localizedDescription, privacy: .public)")
                DispatchQueue.main.async {
                    completion(.failure(NetworkClientError.parsingError))
                }
            }
        }.resume()
    }

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

    func logOrderRequestMetrics(_ metrics: URLSessionTaskMetrics, traceID: String) {
        var dnsDuration: TimeInterval = 0
        var connectDuration: TimeInterval = 0
        var tlsDuration: TimeInterval = 0
        var requestSendDuration: TimeInterval = 0
        var waitForResponseDuration: TimeInterval = 0
        var responseReadDuration: TimeInterval = 0
        var reusedConnections = 0

        for transaction in metrics.transactionMetrics {
            dnsDuration += duration(from: transaction.domainLookupStartDate, to: transaction.domainLookupEndDate)
            connectDuration += duration(from: transaction.connectStartDate, to: transaction.connectEndDate)
            tlsDuration += duration(from: transaction.secureConnectionStartDate, to: transaction.secureConnectionEndDate)
            requestSendDuration += duration(from: transaction.requestStartDate, to: transaction.requestEndDate)
            waitForResponseDuration += duration(from: transaction.requestEndDate, to: transaction.responseStartDate)
            responseReadDuration += duration(from: transaction.responseStartDate, to: transaction.responseEndDate)
            if transaction.isReusedConnection {
                reusedConnections += 1
            }
        }

        let totalDuration = metrics.taskInterval.duration
        Self.logger.info(
            """
            [\(traceID, privacy: .public)] URLSessionTaskMetrics \
            total=\(totalDuration, format: .fixed(precision: 3))s \
            dns=\(dnsDuration, format: .fixed(precision: 3))s \
            connect=\(connectDuration, format: .fixed(precision: 3))s \
            tls=\(tlsDuration, format: .fixed(precision: 3))s \
            requestSend=\(requestSendDuration, format: .fixed(precision: 3))s \
            waitResponse=\(waitForResponseDuration, format: .fixed(precision: 3))s \
            responseRead=\(responseReadDuration, format: .fixed(precision: 3))s \
            redirects=\(metrics.redirectCount) \
            transactions=\(metrics.transactionMetrics.count) \
            reusedConnections=\(reusedConnections)
            """
        )
    }

    func duration(from start: Date?, to end: Date?) -> TimeInterval {
        guard let start, let end else { return 0 }
        return max(0, end.timeIntervalSince(start))
    }

    func subscribeToCartChanges() {
        cartDidChangeObserver = NotificationCenter.default.addObserver(
            forName: .cartDidChange,
            object: nil,
            queue: nil
        ) { [weak self] _ in
            self?.invalidateOrderCache()
        }
    }

    func storeOrderInCache(_ order: CartOrderResponse) {
        cacheQueue.async {
            self.cachedOrder = order
            self.orderCacheTimestamp = Date()
        }
    }

    func cachedOrderIfValid() -> CartOrderResponse? {
        cacheQueue.sync {
            guard
                let cachedOrder,
                let orderCacheTimestamp,
                Date().timeIntervalSince(orderCacheTimestamp) <= Self.orderCacheTTL
            else {
                return nil
            }
            return cachedOrder
        }
    }

    func invalidateOrderCache() {
        cacheQueue.async {
            self.cachedOrder = nil
            self.orderCacheTimestamp = nil
        }
    }
}
