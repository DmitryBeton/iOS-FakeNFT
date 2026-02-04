import Foundation

/// Интерфейс вьюмодели профиля
protocol ProfileViewModelProtocol: AnyObject {
    
    /// Вызывается при изменении состояния профиля
    /// - Parameter state: Текущее состояние профиля
    /// - Note: Используется для обновления UI при смене состояния
    var onStateChange: ((ProfileState) -> Void)? { get set }
    
    /// Сервис для работы с данными профиля
    /// - Note: Используется для загрузки, обновления и сохранения данных
    var service: ProfileServiceProtocol { get }
    
    /// Начать загрузку профиля с сервера
    func loadProfile()
    
    /// Получить UI модель профиля
    ///  - Returns: UI модель профиля для обновления интерфейса
    func getProfile() -> ProfileUI
    
    /// Получить количество NFT профиля
    /// - Returns: Количество NFT в наличии у пользователя
    func myNFTCount() -> Int
    
    /// Получить количество избранных NFT профиля
    /// - Returns: Количество избранных NFT профиля
    func favouritesCount() -> Int
    
    /// Получить короткую строку URL для удобного отображения
    /// - Parameter urlString: Полная строка URL сайта профиля
    /// - Returns: Короткая строка URL  для отображения в UI
    func shortURLString(from urlString: String) -> String
    
    /// Получить полную строку URL сайта профиля
    func websiteURLString() -> String
}
