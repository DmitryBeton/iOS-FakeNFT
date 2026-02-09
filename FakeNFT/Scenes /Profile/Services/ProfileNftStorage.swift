import Foundation

protocol ProfileNftStorageProtocol {
    func saveNfts(_ nfts: [ProfileNft])
    func getNfts() -> [ProfileNft]
}

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
        label: "profile-nft-storage-queue",
        attributes: .concurrent
    )
    
}
