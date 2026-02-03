final class ServicesAssembly {

    private let networkClient: NetworkClient
    private let nftStorage: NftStorage
    private let profileStorage: ProfileStorageProtocol

    init(
        networkClient: NetworkClient,
        nftStorage: NftStorage,
        profileStorage: ProfileStorageProtocol
    ) {
        self.networkClient = networkClient
        self.nftStorage = nftStorage
        self.profileStorage = profileStorage
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
}
