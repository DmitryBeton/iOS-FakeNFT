import Foundation

final class ProfileStorage: ProfileStorageProtocol {
    
    // MARK: - Public Methods
    
    func saveProfile(_ profile: Profile) {
        concurrentQueue.async(flags: .barrier) {
            self.storage = profile
            
            NotificationCenter.default.post(
                name: .profileDidChange,
                object: profile
            )
        }
    }
    
    func getProfile() -> Profile? {
        concurrentQueue.sync {
            storage
        }
    }
    
    // MARK: - Private Properties
    
    private var storage: Profile?
    private let concurrentQueue = DispatchQueue(
        label: "profile-storage-queue",
        attributes: .concurrent
    )
}
