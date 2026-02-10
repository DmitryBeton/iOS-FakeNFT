final class ServicesAssembly {

    private let networkClient: NetworkClient
    private let nftStorage: NftStorage
    private let profileStorage: ProfileStorageProtocol
    private let profileNftStorage: ProfileNftStorageProtocol

    init(
        networkClient: NetworkClient,
        nftStorage: NftStorage,
        profileStorage: ProfileStorageProtocol,
        profileNftStorage: ProfileNftStorageProtocol
    ) {
        self.networkClient = networkClient
        self.nftStorage = nftStorage
        self.profileStorage = profileStorage
        self.profileNftStorage = profileNftStorage
    }

    var nftService: NftService {
        NftServiceImpl(
            networkClient: networkClient,
            storage: nftStorage
        )
    }
    
    var profileService: ProfileServiceProtocol {
        ProfileService(
            networkClient: networkClient,
            storage: profileStorage
        )
    }
    
    var profileNftService: ProfileNftByIdServiceProtocol {
        ProfileNftByIdService(
            networkClient: networkClient,
            storage: profileNftStorage
        )
    }
}
