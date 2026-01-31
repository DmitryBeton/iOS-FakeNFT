import Foundation

typealias ProfileCompletion = (Result<Profile, Error>) -> Void

final class ProfileService: ProfileServiceProtocol {
    
    // MARK: - Public Methods
    
    func loadProfile(completion: @escaping ProfileCompletion) {
        if let profile = storage.getProfile() {
            completion(.success(profile))
            return
        }
        
        let request = LoadProfileRequest()
        networkClient.send(
            request: request,
            type: Profile.self
        ) { [weak storage] result in
            switch result {
            case .success(let profile):
                storage?.saveProfile(profile)
                completion(.success(profile))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    func updateProfile(with profileDto: ProfileDto, completion: @escaping ProfileCompletion) {
        let request = UpdateProfileRequest(dto: profileDto)
        networkClient.send(
            request: request,
            type: Profile.self
        ) { [weak storage] result in
            switch result {
            case .success(let profile):
                storage?.saveProfile(profile)
                completion(.success(profile))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    // MARK: - Private Properties
    
    private let networkClient: NetworkClient
    private let storage: ProfileStorageProtocol
    
    // MARK: - Init
    
    init(networkClient: NetworkClient, storage: ProfileStorageProtocol) {
        self.networkClient = networkClient
        self.storage = storage
    }
    
}
