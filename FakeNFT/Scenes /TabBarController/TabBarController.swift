import UIKit

final class TabBarController: UITabBarController {

    var servicesAssembly: ServicesAssembly!

    private let catalogTabBarItem = UITabBarItem(
        title: NSLocalizedString("Tab.catalog", comment: ""),
        image: UIImage(systemName: "square.stack.3d.up.fill"),
        tag: 0
    )
    
    private let profileTabBarItem = UITabBarItem(
        title: Localization.Profile.tabProfile,
        image: UIImage(resource: .profileTabIcon),
        tag: 2
    )

    override func viewDidLoad() {
        super.viewDidLoad()

        let catalogController = TestCatalogViewController(
            servicesAssembly: servicesAssembly
        )
        catalogController.tabBarItem = catalogTabBarItem
        
        let profileViewModel = ProfileViewModel()
        let profileController = ProfileViewController(viewModel: profileViewModel)
        let profileNavController = UINavigationController(rootViewController: profileController)
        profileNavController.tabBarItem = profileTabBarItem

        viewControllers = [profileNavController, catalogController]

        view.backgroundColor = .systemBackground
    }
}
