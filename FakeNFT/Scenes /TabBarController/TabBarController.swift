import UIKit

final class TabBarController: UITabBarController {

    var servicesAssembly: ServicesAssembly!

    private let catalogTabBarItem = UITabBarItem(
        title: NSLocalizedString("Tab.catalog", comment: ""),
        image: UIImage(systemName: "square.stack.3d.up.fill"),
        tag: 0
    )
    
    private let cartTabBarItem = UITabBarItem(
        title: Localization.Cart.tabBarItemTitle.localized,
        image: UIImage(resource: .tabBasketIcon),
        tag: 1
    )

    override func viewDidLoad() {
        super.viewDidLoad()

        let catalogController = TestCatalogViewController(
            servicesAssembly: servicesAssembly
        )
        catalogController.tabBarItem = catalogTabBarItem
        
        let cartController = CartViewController()
        let cartNavController = UINavigationController(rootViewController: cartController)
        cartNavController.tabBarItem = cartTabBarItem
        viewControllers = [catalogController, cartNavController]

        view.backgroundColor = .systemBackground
    }
}
