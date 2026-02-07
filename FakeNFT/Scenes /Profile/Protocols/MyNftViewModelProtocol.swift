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
    
    /// Сортированные UI данные NFT
    var sortedNfts: [MyNftUI] { get }
    
    /// Начать загрузку NFT с сервера
    func loadNfts()
    
    /// Изменить текущую сортировку во ViewModel
    /// - Parameter sort: Тип сортировки
    /// - Note: После пересортировки NFT уведомляет об изменениях через замыкание
    func changeSort(_ sort: SortOption)
    
    /// Переключить лайк для NFT с заданным id.
    /// Если id уже есть в множестве лайков, он удаляется, иначе – добавляется
    /// - Parameter id: Идентификатор NFT
    func setLike(id: UUID)
    
}
