import UIKit

final class TabBarController: UITabBarController {

    override func viewDidLoad() {
        super.viewDidLoad()
        setupTabs()
    }

    private func setupTabs() {
        let statistics = StatisticsModule.makeRoot()
        statistics.tabBarItem = UITabBarItem(
            title: "Статистика",
            image: UIImage(named: "statisticTabBar"),
            selectedImage: UIImage(named: "statisticTabBar")
        )

        viewControllers = [statistics]
    }
}

