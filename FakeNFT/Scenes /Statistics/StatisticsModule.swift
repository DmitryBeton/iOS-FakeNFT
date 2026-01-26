import UIKit

enum StatisticsModule {

    static func makeRoot() -> UIViewController {
        let presenter = StatisticsPresenter()
        let viewController = StatisticsViewController(presenter: presenter)

        let nav = UINavigationController(rootViewController: viewController)
        nav.navigationBar.tintColor = .label
        nav.tabBarItem = makeTabBarItem()

        return nav
    }

    private static func makeTabBarItem() -> UITabBarItem {
        UITabBarItem(
            title: "Статистика",
            image: UIImage(named: "statisticTabBar"),
            selectedImage: UIImage(named: "statisticTabBar")
        )
    }
}

