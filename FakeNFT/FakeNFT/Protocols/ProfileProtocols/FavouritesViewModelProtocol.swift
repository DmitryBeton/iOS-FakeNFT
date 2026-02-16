import Foundation

protocol FavouritesViewModelProtocol: AnyObject {
    
    /// Вызывается при изменении состояния редактирования профиля
    /// - Parameter state: Текущее состояние экрана "Избранные NFT"
    /// - Note: Используется для обновления UI при смене состояния
    var onStateChange: ((FavouritesState) -> Void)? { get set }
    
    /// Вызывается при изменениях лайков профиля
    /// - Note: Используется для обновления отображения избранных NFT
    var onLikesUpdate: (() -> Void)? { get set }
    
    /// Массив UI-моделей NFT для отображения в интерфейсе
    var nftsUI: [FavouriteNftUI] { get }
    
    /// Загрузить список избранных NFT.
    /// После успешной загрузки обновляет `nftsUI` и состояние вьюмодели
    func loadNfts()
    
    /// Добавить или удалить лайк для NFT с заданным id.
    /// После обновления лайков вызывается замыкание `onLikesUpdate` и обновляется `nftsUI`.
    /// - Parameter id: Идентификатор NFT для переключения лайка
    func setLike(id: UUID)
}
