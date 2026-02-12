/// Интерфейс хранения данных профиля
protocol ProfileStorageProtocol: AnyObject {
    
    /// Сохранить профиль.
    /// При измении профиля отправляет нотификацию `profileDidChange`,
    /// в которой передает обновленный объект.
    /// - Parameter profile: Объект профиля для сохранения
    func saveProfile(_ profile: Profile)
    
    /// Получить профиль
    ///  - Returns: Сохраненный объект `Profile`, если он существует, иначе `nil`
    func getProfile() -> Profile?
    
}
