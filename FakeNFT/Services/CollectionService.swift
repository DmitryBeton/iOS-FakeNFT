import Foundation

typealias CollectionsCompletion = (Result<[NftCollection], Error>) -> Void
typealias CollectionCompletion = (Result<NftCollection, Error>) -> Void

protocol CollectionService {
    func loadCollections(completion: @escaping CollectionsCompletion)
    func loadCollection(id: String, completion: @escaping CollectionCompletion)
}

final class CollectionServiceImpl: CollectionService {

    private let networkClient: NetworkClient
    private let storage: CollectionStorage

    init(networkClient: NetworkClient, storage: CollectionStorage) {
        self.storage = storage
        self.networkClient = networkClient
    }

    func loadCollections(completion: @escaping CollectionsCompletion) {
        if let collections = storage.getCollections() {
            completion(.success(collections))
            return
        }

        let request = CollectionsRequest()
        networkClient.send(request: request, type: [NftCollection].self) { [weak storage] result in
            switch result {
            case .success(let collections):
                storage?.saveCollections(collections)
                completion(.success(collections))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }

    func loadCollection(id: String, completion: @escaping CollectionCompletion) {
        let request = CollectionByIdRequest(id: id)
        networkClient.send(request: request, type: NftCollection.self) { result in
            switch result {
            case .success(let collection):
                completion(.success(collection))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
}
