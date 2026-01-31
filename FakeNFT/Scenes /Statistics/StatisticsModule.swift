import UIKit

enum StatisticsModule {

    static func makeRoot(servicesAssembly: ServicesAssembly) -> UIViewController {

        let presenter = StatisticsPresenter() 
        let viewController = StatisticsViewController(presenter: presenter)

        let nav = UINavigationController(rootViewController: viewController)
        nav.navigationBar.tintColor = .label
        return nav
    }
}

