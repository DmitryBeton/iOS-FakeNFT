import Foundation

final class ProfileNftStorage: ProfileNftStorageProtocol {
    
    // MARK: - Public Methods
    
    func saveNfts(_ nfts: [ProfileNft]) {
        concurrentQueue.async(flags: .barrier) {
            self.storage = nfts
        }
    }
    
    func getNfts() -> [ProfileNft] {
        concurrentQueue.sync {
            storage
        }
    }
    
    // MARK: - Private Properties
    
    private var storage: [ProfileNft] = []
    private let concurrentQueue = DispatchQueue(
        label: "profile-nfts-storage-queue",
        attributes: .concurrent
    )
    
}
