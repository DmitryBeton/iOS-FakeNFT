import UIKit

final class TabBarController: UITabBarController {

    let servicesAssembly: ServicesAssembly

    init(servicesAssembly: ServicesAssembly) {
        self.servicesAssembly = servicesAssembly
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupTabs()
    }

    private func setupTabs() {
        let statistics = StatisticsModule.makeRoot(servicesAssembly: servicesAssembly)
        statistics.tabBarItem = UITabBarItem(
            title: "Статистика",
            image: UIImage(named: "statisticTabBar"),
            selectedImage: UIImage(named: "statisticTabBar")
        )

        viewControllers = [statistics]
    }
}

