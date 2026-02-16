final class ServicesAssembly {

    private let networkClient: NetworkClient
    private let nftStorage: NftStorage

    init(
        networkClient: NetworkClient,
        nftStorage: NftStorage
    ) {
        self.networkClient = networkClient
        self.nftStorage = nftStorage
    }

    var nftService: NftService {
        NftServiceImpl(
            networkClient: networkClient,
            storage: nftStorage
        )
    }

    var statisticsService: StatisticsServiceProtocol {
        StatisticsService(client: networkClient)
    }
    
    var userService: UserServiceProtocol {
        UserService(client: networkClient)
    }
    
    var profileService: ProfileServiceProtocol {
        ProfileService(client: networkClient)
    }

}

