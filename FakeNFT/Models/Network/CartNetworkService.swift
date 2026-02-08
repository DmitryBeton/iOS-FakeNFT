import Foundation

protocol CartServiceProtocol {
    func fetchCartItems(completion: @escaping (Result<[CartItem], Error>) -> Void)
}

final class CartNetworkService: CartServiceProtocol {
    private let networkClient: NetworkClient
    private let nftStorage: NftStorage
    private let orderId: String
    
    init(networkClient: NetworkClient, nftStorage: NftStorage, orderId: String = "1") {
        self.networkClient = networkClient
        self.nftStorage = nftStorage
        self.orderId = orderId
    }

    func fetchCartItems(completion: @escaping (Result<[CartItem], Error>) -> Void) {
        print("[CartNetworkService] Fetching cart items for orderId=\(orderId) host=\(RequestConstants.baseURL)")
        let orderUrlString = "\(RequestConstants.baseURL)/api/v1/orders/\(orderId)"
        print("[CartNetworkService] Order URL: \(orderUrlString)")
        guard let orderUrl = URL(string: orderUrlString) else {
            print("[CartNetworkService] Invalid Order URL")
            completion(.failure(NetworkClientError.urlSessionError))
            return
        }
        var orderRequest = URLRequest(url: orderUrl)
        orderRequest.httpMethod = "GET"
        orderRequest.setValue("application/json", forHTTPHeaderField: "Accept")
        orderRequest.setValue(RequestConstants.token, forHTTPHeaderField: "X-Practicum-Mobile-Token")
        print("[CartNetworkService] Starting order request: \(orderRequest)")
        let session = URLSession.shared
        session.dataTask(with: orderRequest) { [weak self] data, response, error in
            guard let self = self else { return }
            if let http = response as? HTTPURLResponse { print("[CartNetworkService] Order response status: \(http.statusCode)") }
            if let error = error {
                print("[CartNetworkService] Order request failed with error: \(error)")
                completion(.failure(error))
                return
            }
            guard let data = data,
                  let order = try? JSONDecoder().decode(OrderResponse.self, from: data) else {
                let size = data?.count ?? 0
                print("[CartNetworkService] Failed to decode OrderResponse. Data size: \(size) bytes")
                print(data)
                completion(.failure(NetworkClientError.parsingError))
                return
            }
            print("[CartNetworkService] Decoded OrderResponse id=\(order.id) nfts=\(order.nfts)")
            self.loadNfts(ids: order.nfts) { result in
                print("[CartNetworkService] loadNfts completed with result: \(result)")
                completion(result)
            }
        }.resume()
    }
    
    private func loadNfts(ids: [String], completion: @escaping (Result<[CartItem], Error>) -> Void) {
        print("[CartNetworkService] Loading NFTs: ids=\(ids)")
        let group = DispatchGroup()
        var cartItems: [CartItem] = []
        var error: Error?
        let lock = NSLock()
        for id in ids {
            group.enter()
            let nftUrlString = "\(RequestConstants.baseURL)/api/v1/nft/\(id)"
            print("[CartNetworkService] NFT URL for id=\(id): \(nftUrlString)")
            guard let nftUrl = URL(string: nftUrlString) else {
                print("[CartNetworkService] Invalid NFT URL for id=\(id)")
                lock.lock()
                error = NetworkClientError.urlSessionError
                lock.unlock()
                group.leave()
                continue
            }
            var nftRequest = URLRequest(url: nftUrl)
            nftRequest.httpMethod = "GET"
            nftRequest.setValue("application/json", forHTTPHeaderField: "Accept")
            nftRequest.setValue(RequestConstants.token, forHTTPHeaderField: "X-Practicum-Mobile-Token")
            print("[CartNetworkService] Starting NFT request for id=\(id): \(nftRequest)")
            URLSession.shared.dataTask(with: nftRequest) { [weak self] data, response, err in
                defer { group.leave() }
                guard let self = self else { return }
                if let http = response as? HTTPURLResponse { print("[CartNetworkService] NFT response status for id=\(id): \(http.statusCode)") }
                if let err = err {
                    print("[CartNetworkService] NFT request failed for id=\(id) error: \(err)")
                    lock.lock()
                    error = err
                    lock.unlock()
                    return
                }
                guard let data = data,
                      let nft = try? JSONDecoder().decode(Nft.self, from: data) else {
                    let size = data?.count ?? 0
                    print("[CartNetworkService] Failed to decode NFT for id=\(id). Data size: \(size) bytes")
                    lock.lock()
                    error = NetworkClientError.parsingError
                    lock.unlock()
                    return
                }
                print("[CartNetworkService] Decoded NFT id=\(nft.id) name=\(nft.name) price=\(nft.price)")
                self.nftStorage.saveNft(nft)
                print("[CartNetworkService] Saved NFT to storage id=\(nft.id)")
                let cartItem = CartItem(
                    id: nft.id,
                    name: nft.name,
                    images: nft.images,
                    rating: nft.rating,
                    price: nft.price
                )
                lock.lock()
                cartItems.append(cartItem)
                print("[CartNetworkService] Appended CartItem id=\(cartItem.id). Total so far: \(cartItems.count)")
                lock.unlock()
            }.resume()
        }
        group.notify(queue: .main) {
            print("[CartNetworkService] All NFT requests finished. error=\(String(describing: error)) count=\(cartItems.count)")
            if let error = error {
                completion(.failure(error))
            } else {
                completion(.success(cartItems))
            }
        }
    }
}

private struct OrderResponse: Decodable {
    let nfts: [String]
    let id: String
}
