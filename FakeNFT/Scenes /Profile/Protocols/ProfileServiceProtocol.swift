/// Интерфейс сервиса загрузки данных профиля из сети
protocol ProfileServiceProtocol {
    
    /// Загрузить данные профиля
    /// - Parameter completion: Вызывается после завершения загрузки профиля
    ///     - При успехе (`.success`) возвращает объект `Profile`
    ///     - При ошибке (`.failure`) возвращает `Error`
    /// - Note: Если данные уже были загружены, они возвращаются сразу.
    ///         Если данные отсутствуют выполняется `GET` запрос
    func loadProfile(completion: @escaping ProfileCompletion)
    
    /// Обновить данные профиля на сервере
    /// - Parameter profileDto: DTO с обновленными данными профиля, которые необходимо сохранить на сервере
    /// - Parameter completion: Вызывается после завершения обновления профиля
    ///     - При успехе (`.success`) возвращает обновленный объект `Profile`
    ///     - При ошибке (`.failure`) возвращает `Error`
    func updateProfile(with profileDto: ProfileDto, completion: @escaping ProfileCompletion)
}
