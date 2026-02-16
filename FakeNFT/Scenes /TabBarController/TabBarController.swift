import UIKit

final class TabBarController: UITabBarController {

    private let servicesAssembly: ServicesAssembly

    private let profileTabBarItem = UITabBarItem(
        title: Localization.Profile.tabProfile,
        image: UIImage(resource: .profileTabIcon),
        tag: 0
    )

    private let catalogTabBarItem = UITabBarItem(
        title: Localization.Catalog.catalog.localized,
        image: UIImage(resource: .catalogTab),
        tag: 1
    )

    private let cartTabBarItem = UITabBarItem(
        title: Localization.Cart.tabBarItemTitle.localized,
        image: UIImage(resource: .tabBasketIcon),
        tag: 2
    )
    
    private let statisticsTabBarItem = UITabBarItem(
        title: "Статистика",
        image: UIImage(resource: .statisticTabBar),
        tag: 3
    )

    init(servicesAssembly: ServicesAssembly) {
        self.servicesAssembly = servicesAssembly
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()

        // 1) Профиль
        let profileNavigationController = buildProfileController()

        // 3) Каталог
        let catalogController = CatalogViewController(servicesAssembly: servicesAssembly)
        let catalogNavigationController = UINavigationController(rootViewController: catalogController)
        catalogNavigationController.tabBarItem = catalogTabBarItem

        // 4) Корзина
        let cartViewModel = CartViewModel(service: servicesAssembly.cartService)
        let cartController = CartViewController(viewModel: cartViewModel, router: CartRouter())
        let cartNavigationController = UINavigationController(rootViewController: cartController)
        cartNavigationController.tabBarItem = cartTabBarItem
        
        // 2) Статистика
        let statisticsViewModel = StatisticsViewModel(service: servicesAssembly.statisticsService)
        let statisticsController = StatisticsViewController(
            viewModel: statisticsViewModel,
            servicesAssembly: servicesAssembly
        )
        let statisticsNavigationController = UINavigationController(rootViewController: statisticsController)
        statisticsNavigationController.tabBarItem = statisticsTabBarItem

        viewControllers = [
            profileNavigationController,
            catalogNavigationController,
            cartNavigationController,
            statisticsNavigationController
        ]
    }

    private func setupView() {
        view.backgroundColor = .systemBackground
        tabBar.unselectedItemTintColor = UIColor(resource: .nftBlack)

        let appearance = UITabBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = UIColor(resource: .nftWhite)
        tabBar.standardAppearance = appearance
        tabBar.scrollEdgeAppearance = appearance
    }

    private func buildProfileController() -> UINavigationController {
        let viewModel = ProfileViewModel(profileService: servicesAssembly.profileService)
        let controller = ProfileViewController(viewModel: viewModel, servicesAssembly: servicesAssembly)
        let navController = UINavigationController(rootViewController: controller)
        navController.tabBarItem = profileTabBarItem
        return navController
    }
}

