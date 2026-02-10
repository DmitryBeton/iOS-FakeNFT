import UIKit

final class TabBarController: UITabBarController {
    
    //MARK: - Properties

    private let servicesAssembly: ServicesAssembly

    private let catalogTabBarItem = UITabBarItem(
        title: Localization.Catalog.catalog.localized,
        image: UIImage(resource: .catalogTab),
        tag: 0
    )
    
    //MARK: - Init
    
    init(servicesAssembly: ServicesAssembly) {
        self.servicesAssembly = servicesAssembly
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()

        let catalogController = CatalogViewController(
            servicesAssembly: servicesAssembly
        )
        let catalogNavigationController = UINavigationController(rootViewController: catalogController)
        catalogNavigationController.tabBarItem = catalogTabBarItem

        viewControllers = [catalogNavigationController]
    }
    
    //MARK: - Methods
    
    private func setupView() {
        view.backgroundColor = .systemBackground
        tabBar.unselectedItemTintColor = UIColor(resource: .nftBlack)
    }
}
