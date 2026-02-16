import Foundation

protocol ProfileNftByIdServiceProtocol {
    
    /// Загрузить NFT по заданному массиву id
    /// - Parameters:
    ///    - ids: Массив идентификаторов NFT для загрузки
    ///    - completion: Вызывается после завершения загрузки NFT
    ///         - При успехе (`.success`) возвращает массив объектов `NFT`
    ///         - При ошибке (`.failure`) возвращает `Error`
    /// - Note: Если данные уже были загружены, они возвращаются сразу.
    ///         Если данные отсутствуют выполняется `GET` запрос
    func loadNfts(withIds ids: [UUID], completion: @escaping ProfileNftsCompletion)
    
}
