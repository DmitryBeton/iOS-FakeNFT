protocol SortOptionStorageProtocol: AnyObject {
    
    /// Способ сортировки, хранящийся в UserDefaults.
    /// Если нет сохраненной сортировки, возвращает сортировку по рейтингу
    var sortOption: SortOption { get set }
    
}
