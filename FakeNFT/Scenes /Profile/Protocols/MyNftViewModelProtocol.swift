import Foundation

protocol MyNftViewModelProtocol: AnyObject {
    
    /// Вызывается при изменении состояния редактирования профиля
    /// - Parameter state: Текущее состояние экрана "Мои NFT"
    /// - Note: Используется для обновления UI при смене состояния
    var onStateChange: ((MyNftState) -> Void)? { get set }
    
    /// Вызывается при изменении способа сортировки
    /// - Note: Используется для пересортировки ячеек таблицы
    var onSortChange: (() -> Void)? { get set }
    
    /// Вызывается при изменениях лайков профиля
    /// - Note: Используется для обновления отображения лайков
    var onLikesUpdate: (() -> Void)? { get set }
    
    /// Отсортированный массив UI-моделей NFT для отображения в интерфейсе
    var sortedNfts: [MyNftUI] { get }
    
    /// Загрузить список NFT профиял
    /// После успешной загрузки обновляет `sortedNfts` и состояние вьюмодели
    func loadNfts()
    
    /// Изменить текущую сортировку во ViewModel
    /// - Parameter sort: Тип сортировки
    /// - Note: После пересортировки NFT уведомляет об изменениях через замыкание
    func changeSort(_ sort: SortOption)
    
    /// Добавить или удалить лайк для NFT с заданным id.
    /// После обновления лайков вызывается замыкание `onLikesUpdate` и обновляется `sortedNfts`.
    /// - Parameter id: Идентификатор NFT для переключения лайка
    func setLike(id: UUID)
    
}
