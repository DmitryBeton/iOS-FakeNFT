protocol SortOptionStorageProtocol: AnyObject {
    
    /// Способ сортировки, хранящийся в UserDefaults.
    /// Если нет сохраненной сортировки, возвращает сортировку по имени
    var sortOption: SortOption { get set }
    
}
