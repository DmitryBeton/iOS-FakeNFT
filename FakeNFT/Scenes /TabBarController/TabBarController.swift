import UIKit

final class TabBarController: UITabBarController {

    var servicesAssembly: ServicesAssembly!

    private let catalogTabBarItem = UITabBarItem(
        title: NSLocalizedString("Tab.catalog", comment: ""),
        image: UIImage(systemName: "square.stack.3d.up.fill"),
        tag: 1
    )
    
    private let profileTabBarItem = UITabBarItem(
        title: Localization.Profile.tabProfile,
        image: UIImage(resource: .profileTabIcon),
        tag: 0
    )

    override func viewDidLoad() {
        super.viewDidLoad()

        let catalogController = TestCatalogViewController(
            servicesAssembly: servicesAssembly
        )
        catalogController.tabBarItem = catalogTabBarItem
        
        let profileController = buildProfileController()

        viewControllers = [profileController, catalogController]

        view.backgroundColor = .systemBackground
    }
    
    private func buildProfileController() -> UINavigationController {
        let viewModel = ProfileViewModel(service: servicesAssembly.profileService)
        let controller = ProfileViewController(viewModel: viewModel)
        let navController = UINavigationController(rootViewController: controller)
        navController.tabBarItem = profileTabBarItem
        
        return navController
    }
}
