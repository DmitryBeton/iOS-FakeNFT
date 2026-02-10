import UIKit

final class TabBarController: UITabBarController {

    var servicesAssembly: ServicesAssembly!

    private let cartTabBarItem = UITabBarItem(
        title: Localization.Cart.tabBarItemTitle.localized,
        image: UIImage(resource: .tabBasketIcon),
        tag: 0
    )

    override func viewDidLoad() {
        super.viewDidLoad()

        let cartController = CartViewController(servicesAssembly: servicesAssembly)

        let cartNavController = UINavigationController(rootViewController: cartController)
        cartNavController.tabBarItem = cartTabBarItem
        viewControllers = [cartNavController]

        let appearance = UITabBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = UIColor(resource: .nftWhite)

        tabBar.standardAppearance = appearance
        tabBar.scrollEdgeAppearance = appearance

    }
}
