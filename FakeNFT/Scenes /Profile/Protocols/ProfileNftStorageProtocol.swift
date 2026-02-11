protocol ProfileNftStorageProtocol: AnyObject {
    
    /// Сохранить массив NFT
    /// - Parameter nfts: Массив объектов NFT для сохранения
    func saveNfts(_ nfts: [ProfileNft])
    
    /// Получить массив NFT
    /// - Returns: Сохраненные объекты NFT, если они существуют, иначе пустой массив
    func getNfts() -> [ProfileNft]
    
}
