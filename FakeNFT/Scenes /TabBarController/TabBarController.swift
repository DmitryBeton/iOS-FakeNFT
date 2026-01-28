import UIKit

final class TabBarController: UITabBarController {

    var servicesAssembly: ServicesAssembly!

    private let catalogTabBarItem = UITabBarItem(
        title: Localization.Catalog.catalog.localized,
        image: UIImage(resource: .catalogTab),
        tag: 0
    )

    override func viewDidLoad() {
        super.viewDidLoad()

        let catalogController = CatalogViewController(
            servicesAssembly: servicesAssembly
        )

        let catalogNavigationController = UINavigationController(rootViewController: catalogController)
        catalogNavigationController.tabBarItem = catalogTabBarItem

        viewControllers = [catalogNavigationController]

        view.backgroundColor = .systemBackground
        tabBar.unselectedItemTintColor = UIColor(resource: .nftBlack)
    }
}
