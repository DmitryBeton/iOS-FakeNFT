import Foundation

typealias ProfileNftsCompletion = (Result<[ProfileNft], Error>) -> Void
typealias ProfileNftCompletion = (Result<ProfileNft, Error>) -> Void

final class ProfileNftByIdService: ProfileNftByIdServiceProtocol {
    
    // MARK: - Public Methods
    
    func loadNfts(withIds ids: [UUID], completion: @escaping ProfileNftsCompletion) {
        if ids.isEmpty {
            completion(.success([]))
            return
        }
        
        let storedNfts = storage.getNfts()
        if !storedNfts.isEmpty {
            completion(.success(storedNfts))
            return
        }
        
        let group = DispatchGroup()
        let queue = DispatchQueue(label: "profile-nfts-result-queue")
        
        var nfts: [ProfileNft] = []
        var firstError: Error?
        
        for id in ids {
            group.enter()
            loadNft(withId: id) { result in
                queue.sync {
                    switch result {
                    case .success(let nft):
                        nfts.append(nft)
                    case .failure(let error):
                        if firstError == nil {
                            firstError = error
                        }
                    }
                }
                group.leave()
            }
        }
        
        group.notify(queue: .main) { [weak storage] in
            if let error = firstError {
                completion(.failure(error))
            } else {
                storage?.saveNfts(nfts)
                completion(.success(nfts))
            }
        }
    }
    
    // MARK: - Private Properties
    
    private let networkClient: NetworkClient
    private let storage: ProfileNftStorageProtocol
    
    // MARK: - Init
    
    init(networkClient: NetworkClient, storage: ProfileNftStorageProtocol) {
        self.networkClient = networkClient
        self.storage = storage
    }
    
    // MARK: - Private Methods
    
    private func loadNft(withId id: UUID, completion: @escaping ProfileNftCompletion) {
        let request = LoadNftRequest(id: id)
        networkClient.send(
            request: request,
            type: ProfileNft.self
        ) { result in
            switch result {
            case .success(let nft):
                completion(.success(nft))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
}
