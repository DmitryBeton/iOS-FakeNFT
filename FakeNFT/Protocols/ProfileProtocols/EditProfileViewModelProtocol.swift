/// Интерфейс вьюмодели изменения профиля
protocol EditProfileViewModelProtocol: AnyObject {
    
    /// Вызывается при изменении состояния редактирования профиля
    /// - Parameter state: Текущее состояние профиля
    /// - Note: Используется для обновления UI при смене состояния
    var onStateChange: ((EditProfileState) -> Void)? { get set }
    
    /// Вызывается при обновлении аватара
    /// - Note: Используется для обновления картинки аватара, данные могут браться из `profile` вьюмодели
    var onAvatarChange: (() -> Void)? { get set }
    
    /// Текущие данные профиля
    var profile: ProfileUI { get }
    
    /// Проверяет, есть ли изменения в профиле
    /// - Note: Возвращает `true`, если текущие данные профиля отличаются от данных при инициализации
    var hasChanges: Bool { get }
    
    /// Загрузить инициализированный профиль во `ViewController`
    func loadProfile()
    
    /// Изменить аватар профиля
    /// - Parameter urlString: Строка URL аватара
    func changeAvatar(urlString: String)
    
    /// Изменить имя профиля
    /// - Parameter name: Имя профиля
    func changeName(_ name: String)
    
    /// Изменить описание профиля
    /// - Parameter description: Описание профиля
    func changeDescription(_ description: String)
    
    /// Изменить ссылку на сайт профиля
    /// - Parameter urlString: Строка URL сайта профиля
    func changeWebsite(urlString: String)
    
    /// Отправить `PUT` запрос на обновление данных профиля
    /// - Note: При успешном запросе отправляет `onChangesSaved` в ProfileViewModel и закрывает экран.
    ///         При ошибке отображается сообщение об ошибке во `ViewController`
    func saveChanges()
    
}
