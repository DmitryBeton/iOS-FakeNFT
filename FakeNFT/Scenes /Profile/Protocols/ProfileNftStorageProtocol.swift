protocol ProfileNftStorageProtocol: AnyObject {
    
    func saveNfts(_ nfts: [ProfileNft])
    func getNfts() -> [ProfileNft]
    
}
