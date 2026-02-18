import Foundation
import OSLog

typealias NftCompletion = (Result<Nft, Error>) -> Void

protocol NftService {
    func loadNft(id: String, completion: @escaping NftCompletion)
}

final class NftServiceImpl: NftService {
    private static let logger = Logger(subsystem: "com.fakenft.app", category: "NftService")

    private let networkClient: NetworkClient
    private let storage: NftStorage
    private let callbackQueue = DispatchQueue(label: "com.fakenft.nftservice.callback", qos: .userInitiated)

    init(networkClient: NetworkClient, storage: NftStorage) {
        self.storage = storage
        self.networkClient = networkClient
    }

    func loadNft(id: String, completion: @escaping NftCompletion) {
        Self.logger.debug("[\(LogTimestamp.current(), privacy: .public)] Start load NFT. id=\(id, privacy: .public)")
        if let nft = storage.getNft(with: id) {
            Self.logger.debug("[\(LogTimestamp.current(), privacy: .public)] Return NFT from storage. id=\(id, privacy: .public)")
            callbackQueue.async {
                completion(.success(nft))
            }
            return
        }

        Self.logger.debug("[\(LogTimestamp.current(), privacy: .public)] Storage miss. Requesting NFT from network. id=\(id, privacy: .public)")
        let request = NFTRequest(id: id)
        networkClient.send(
            request: request,
            type: Nft.self,
            completionQueue: callbackQueue
        ) { [weak storage] result in
            switch result {
            case .success(let nft):
                Self.logger.debug("[\(LogTimestamp.current(), privacy: .public)] NFT loaded from network. id=\(nft.id, privacy: .public)")
                storage?.saveNft(nft)
                completion(.success(nft))
            case .failure(let error):
                Self.logger.error("[\(LogTimestamp.current(), privacy: .public)] Failed to load NFT. id=\(id, privacy: .public), error=\(String(describing: error), privacy: .public)")
                completion(.failure(error))
            }
        }
    }
}
