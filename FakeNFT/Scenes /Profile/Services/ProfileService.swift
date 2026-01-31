import Foundation

typealias ProfileCompletion = (Result<Profile, Error>) -> Void

final class ProfileService {
    
    private let networkClient: NetworkClient
    private let storage: ProfileStorage
    
    init(networkClient: NetworkClient, storage: ProfileStorage) {
        self.networkClient = networkClient
        self.storage = storage
    }
    
    func loadProfile(completion: @escaping ProfileCompletion) {
        
    }
    
    func updateProfile(completion: @escaping ProfileCompletion) {
        
    }
    
}
