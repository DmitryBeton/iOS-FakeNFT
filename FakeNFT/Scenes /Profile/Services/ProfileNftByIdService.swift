import Foundation

typealias ProfileNftsCompletion = (Result<[ProfileNft], Error>) -> Void
typealias ProfileNftCompletion = (Result<ProfileNft, Error>) -> Void

protocol ProfileNftByIdServiceProtocol {
    func loadNfts(withIds ids: [UUID], completion: @escaping ProfileNftsCompletion)
}

final class ProfileNftByIdService: ProfileNftByIdServiceProtocol {
    
    // MARK: - Public Methods
    
    func loadNfts(withIds ids: [UUID], completion: @escaping ProfileNftsCompletion) {
        
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
    
    private func loadNft(withId id: UUID) {
        let request = LoadNftRequest(id: id)
    }
    
}
