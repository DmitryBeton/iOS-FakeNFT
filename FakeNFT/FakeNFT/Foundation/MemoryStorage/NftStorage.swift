import Foundation
import OSLog

protocol NftStorage: AnyObject {
    func saveNft(_ nft: Nft)
    func getNft(with id: String) -> Nft?
}

// Пример простого класса, который сохраняет данные из сети
final class NftStorageImpl: NftStorage {
    private static let logger = Logger(subsystem: "com.fakenft.app", category: "NftStorage")
    private var storage: [String: Nft] = [:]

    private let syncQueue = DispatchQueue(label: "sync-nft-queue")

    func saveNft(_ nft: Nft) {
        syncQueue.async { [weak self] in
            self?.storage[nft.id] = nft
            Self.logger.debug("[\(LogTimestamp.current(), privacy: .public)] NFT saved to memory storage. id=\(nft.id, privacy: .public)")
        }
    }

    func getNft(with id: String) -> Nft? {
        syncQueue.sync {
            let nft = storage[id]
            if nft == nil {
                Self.logger.debug("[\(LogTimestamp.current(), privacy: .public)] NFT storage miss. id=\(id, privacy: .public)")
            } else {
                Self.logger.debug("[\(LogTimestamp.current(), privacy: .public)] NFT storage hit. id=\(id, privacy: .public)")
            }
            return nft
        }
    }
}
