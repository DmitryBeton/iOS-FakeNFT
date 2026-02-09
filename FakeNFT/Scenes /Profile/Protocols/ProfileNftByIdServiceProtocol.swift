import Foundation

protocol ProfileNftByIdServiceProtocol {
    
    func loadNfts(withIds ids: [UUID], completion: @escaping ProfileNftsCompletion)
    
}
