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
        
        let profileController = ProfileViewController()
        let profileNavController = UINavigationController(rootViewController: profileController)
        profileNavController.tabBarItem = profileTabBarItem

        viewControllers = [profileNavController, catalogController]

        view.backgroundColor = .systemBackground
    }
}
