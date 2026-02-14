import Foundation

/// Интерфейс вьюмодели профиля
protocol ProfileViewModelProtocol: AnyObject {
    
    /// Вызывается при изменении состояния профиля
    /// - Parameter state: Текущее состояние профиля
    /// - Note: Используется для обновления UI при смене состояния
    var onStateChange: ((ProfileState) -> Void)? { get set }
    
    /// Текущее состояние профиля. Доступно только для чтения.
    var state: ProfileState { get }
    
    /// Начать загрузку профиля с сервера
    func loadProfile()
    
    /// Получить UI модель профиля
    ///  - Returns: UI модель профиля для обновления интерфейса
    func getProfile() -> ProfileUI
    
    /// Получить количество NFT профиля
    /// - Returns: Количество NFT в наличии у пользователя
    func myNftCount() -> Int
    
    /// Получить количество избранных NFT профиля
    /// - Returns: Количество избранных NFT профиля
    func favouritesCount() -> Int
    
    /// Получить полную строку URL сайта профиля
    func websiteURLString() -> String
    
}
