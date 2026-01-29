import UIKit

enum StatisticsModule {

    static func makeRoot() -> UIViewController {
        let presenter = StatisticsPresenter()
        let viewController = StatisticsViewController(presenter: presenter)

        let nav = UINavigationController(rootViewController: viewController)
        nav.navigationBar.tintColor = .label

        return nav
    }
}

