import Foundation

final class CatalogViewModel {

    // MARK: - Properties

    var onCollectionsUpdated: (([CatalogCollectionModel]) -> Void)?
    var onLoadingStateChanged: ((Bool) -> Void)?
    var onError: ((String) -> Void)?

    private let collectionService: CollectionService

    private var collections: [CatalogCollectionModel] = []
    private var currentSortType: SortType? {
        didSet {
            saveSortType()
        }
    }

    private enum UserDefaultsKeys {
        static let sortType = "CatalogSortType"
    }

    // MARK: - Init

    init(collectionService: CollectionService) {
        self.collectionService = collectionService
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

        collectionService.loadCollections { [weak self] result in
            guard let self = self else { return }

            self.onLoadingStateChanged?(false)

            switch result {
            case .success(let nftCollections):
                var models = nftCollections.map { collection in
                    CatalogCollectionModel(
                        id: collection.id,
                        name: collection.name,
                        cover: collection.cover,
                        nftCount: collection.nfts.count
                    )
                }
                if let sortType = self.currentSortType {
                    self.applySorting(sortType, to: &models)
                }
                self.collections = models
                self.onCollectionsUpdated?(models)
            case .failure(let error):
                self.onError?(error.localizedDescription)
            }
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
}

enum SortType: String {
    case byName = "name"
    case byNftCount = "nftCount"
}
