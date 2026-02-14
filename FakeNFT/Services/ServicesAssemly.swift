final class ServicesAssembly {
    
    private let networkClient: NetworkClient
    private let nftStorage: NftStorage
    
    private let collectionStorage: CollectionStorage

    private let profileStorage: ProfileStorageProtocol
    private let myNftStorage: ProfileNftStorageProtocol
    private let favouritesStorage: ProfileNftStorageProtocol
    
    init(
        networkClient: NetworkClient,
        nftStorage: NftStorage,
        collectionStorage: CollectionStorage = CollectionStorageImpl(),
        profileStorage: ProfileStorageProtocol,
        myNftStorage: ProfileNftStorageProtocol,
        favouritesStorage: ProfileNftStorageProtocol
    ) {
        self.networkClient = networkClient
        self.nftStorage = nftStorage
        self.collectionStorage = collectionStorage
        self.profileStorage = profileStorage
        self.myNftStorage = myNftStorage
        self.favouritesStorage = favouritesStorage
    }
    
    var nftService: NftService {
        NftServiceImpl(
            networkClient: networkClient,
            storage: nftStorage
        )
    }

    var collectionService: CollectionService {
        CollectionServiceImpl(
            networkClient: networkClient,
            storage: collectionStorage
        )
    }
    
    var profileService: ProfileServiceProtocol {
        ProfileService(
            networkClient: networkClient,
            storage: profileStorage
        )
    }
    
    var myNftService: ProfileNftByIdServiceProtocol {
        ProfileNftByIdService(
            networkClient: networkClient,
            storage: myNftStorage
        )
    }
    
    var favouritesService: ProfileNftByIdServiceProtocol {
        ProfileNftByIdService(
            networkClient: networkClient,
            storage: favouritesStorage
        )
    }
    
}
