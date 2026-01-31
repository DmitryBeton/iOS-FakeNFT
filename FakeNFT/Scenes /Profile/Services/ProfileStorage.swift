import Foundation

final class ProfileStorage: ProfileStorageProtocol {
    
    // MARK: - Public Methods
    
    func saveProfile(_ profile: Profile) {
        syncQueue.async { [weak self] in
            self?.storage = profile
        }
    }
    
    func getProfile() -> Profile? {
        syncQueue.sync {
            storage
        }
    }
    
    // MARK: - Private Properties
    
    private var storage: Profile?
    private let syncQueue = DispatchQueue(label: "sync-profile-queue")
    
}
