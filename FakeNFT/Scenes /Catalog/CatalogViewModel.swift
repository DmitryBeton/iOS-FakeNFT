import Foundation

final class CatalogViewModel {
    
    // MARK: - Properties
    
    // Колбэк для обновления UI (View подписывается на это)
    var onCollectionsUpdated: (([CatalogCollectionModel]) -> Void)?
    var onLoadingStateChanged: ((Bool) -> Void)?
    var onError: ((String) -> Void)?
    
    private var collections: [CatalogCollectionModel] = []
    
    // MARK: - Public Methods
    
    // Вызывается из ViewController когда экран загружается
    func viewDidLoad() {
        loadCollections()
    }
    
    // Количество коллекций для tableView
    func numberOfCollections() -> Int {
        return collections.count
    }
    
    // Получить конкретную коллекцию по индексу
    func collection(at index: Int) -> CatalogCollectionModel {
        return collections[index]
    }
    
    // Сортировка (добавим позже)
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
                name: "Bored Ape Yacht Club",
                coverImageUrl: "mock_image_1", // пока используем имя из Assets
                nftCount: 10000
            ),
            CatalogCollectionModel(
                id: "2",
                name: "CryptoPunks",
                coverImageUrl: "mock_image_2",
                nftCount: 10000
            ),
            CatalogCollectionModel(
                id: "3",
                name: "Azuki",
                coverImageUrl: "mock_image_3",
                nftCount: 10000
            )
            // Добавьте больше для тестирования скролла
        ]
    }
}

// Enum для типов сортировки (добавим позже)
enum SortType {
    case byName
    case byNftCount
}

