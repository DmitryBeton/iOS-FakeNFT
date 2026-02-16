import Foundation

protocol CollectionStorage: AnyObject {
    func saveCollections(_ collections: [NftCollection])
    func getCollections() -> [NftCollection]?
}

final class CollectionStorageImpl: CollectionStorage {
    private var storage: [NftCollection]?

    private let syncQueue = DispatchQueue(label: "sync-collection-queue")

    func saveCollections(_ collections: [NftCollection]) {
        syncQueue.async { [weak self] in
            self?.storage = collections
        }
    }

    func getCollections() -> [NftCollection]? {
        syncQueue.sync {
            storage
        }
    }
}
