import Foundation

final class CatalogViewModel {
    
    // MARK: - Properties
    
    var onCollectionsUpdated: (([CatalogCollectionModel]) -> Void)?
    var onLoadingStateChanged: ((Bool) -> Void)?
    var onError: ((String) -> Void)?
    
    private var collections: [CatalogCollectionModel] = []
    
    // MARK: - Public Methods
    
    func viewDidLoad() {
        loadCollections()
    }
    
    func numberOfCollections() -> Int {
        return collections.count
    }
    
    // Получить конкретную коллекцию по индексу
    func collection(at index: Int) -> CatalogCollectionModel {
        return collections[index]
    }
    
    func sortCollections(by sortType: SortType) {
        // Здесь будет логика сортировки
    }
    
    // MARK: - Private Methods
    
    private func loadCollections() {
        // Показываем индикатор загрузки
        onLoadingStateChanged?(true)
        
        // Симулируем загрузку с сервера (задержка 1 секунда)
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { [weak self] in
            // Создаём моковые данные
            let mockCollections = self?.createMockCollections() ?? []
            self?.collections = mockCollections
            
            // Скрываем индикатор загрузки
            self?.onLoadingStateChanged?(false)
            
            // Уведомляем View что данные обновились
            self?.onCollectionsUpdated?(mockCollections)
        }
    }
    
    // Создание моковых данных для тестирования верстки
    private func createMockCollections() -> [CatalogCollectionModel] {
        return [
            CatalogCollectionModel(
                id: "1",
                name: "Peach",
                coverImages: ["mock_image_1", "mock_image_2", "mock_image_3"],
                nftCount: 11
            ),
            CatalogCollectionModel(
                id: "2",
                name: "Blue",
                coverImages: ["mock_image_1", "mock_image_2", "mock_image_3"],
                nftCount: 6
            ),
            CatalogCollectionModel(
                id: "3",
                name: "Brown",
                coverImages: ["mock_image_1", "mock_image_2", "mock_image_3"],
                nftCount: 8
            ),
            CatalogCollectionModel(
                id: "4",
                name: "Green",
                coverImages: ["mock_image_1", "mock_image_2", "mock_image_3"],
                nftCount: 15
            ),
            CatalogCollectionModel(
                id: "5",
                name: "Purple",
                coverImages: ["mock_image_1", "mock_image_2", "mock_image_3"],
                nftCount: 20
            )
        ]
    }
}

// Enum для типов сортировки (добавим позже)
enum SortType {
    case byName
    case byNftCount
}

