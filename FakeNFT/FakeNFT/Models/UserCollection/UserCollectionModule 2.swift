import UIKit

enum UserCollectionModule {
    static func make(userId: String, servicesAssembly: ServicesAssembly) -> UIViewController {

        let viewModel = UserCollectionViewModel(
            userId: userId,
            userService: servicesAssembly.userService,
            nftService: servicesAssembly.nftService,
            profileService: servicesAssembly.profileService
        )

        return UserCollectionViewController(viewModel: viewModel)
    }
}
