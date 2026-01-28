import Foundation

final class CatalogViewModel {

    // MARK: - Properties

    var onCollectionsUpdated: (([CatalogCollectionModel]) -> Void)?
    var onLoadingStateChanged: ((Bool) -> Void)?
    var onError: ((String) -> Void)?

    private var collections: [CatalogCollectionModel] = []
    private var currentSortType: SortType? {
        didSet {
            saveSortType()
        }
    }

    private enum UserDefaultsKeys {
        static let sortType = "CatalogSortType"
    }
    
    // MARK: - Public Methods
    
    func viewDidLoad() {
        loadSortType()
        loadCollections()
    }
    
    func numberOfCollections() -> Int {
        return collections.count
    }
    
    func collection(at index: Int) -> CatalogCollectionModel {
        return collections[index]
    }
    
    func sortCollections(by sortType: SortType) {
        currentSortType = sortType

        switch sortType {
        case .byName:
            collections.sort { $0.name < $1.name }
        case .byNftCount:
            collections.sort { $0.nftCount > $1.nftCount }
        }

        onCollectionsUpdated?(collections)
    }
    
    // MARK: - Private Methods
    
    private func loadCollections() {
        onLoadingStateChanged?(true)

        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { [weak self] in
            guard let self = self else { return }

            var mockCollections = self.createMockCollections()
            self.collections = mockCollections

            if let sortType = self.currentSortType {
                self.applySorting(sortType, to: &mockCollections)
            }

            self.onLoadingStateChanged?(false)

            self.onCollectionsUpdated?(mockCollections)
        }
    }

    private func applySorting(_ sortType: SortType, to collections: inout [CatalogCollectionModel]) {
        switch sortType {
        case .byName:
            collections.sort { $0.name < $1.name }
        case .byNftCount:
            collections.sort { $0.nftCount > $1.nftCount }
        }
    }

    // MARK: - UserDefaults

    private func saveSortType() {
        guard let sortType = currentSortType else {
            UserDefaults.standard.removeObject(forKey: UserDefaultsKeys.sortType)
            return
        }
        UserDefaults.standard.set(sortType.rawValue, forKey: UserDefaultsKeys.sortType)
    }

    private func loadSortType() {
        guard let rawValue = UserDefaults.standard.string(forKey: UserDefaultsKeys.sortType),
              let sortType = SortType(rawValue: rawValue) else {
            return
        }
        currentSortType = sortType
    }
    
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

enum SortType: String {
    case byName = "name"
    case byNftCount = "nftCount"
}

