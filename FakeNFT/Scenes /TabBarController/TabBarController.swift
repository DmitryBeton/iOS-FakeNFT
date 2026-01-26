import UIKit

final class TabBarController: UITabBarController {

    var servicesAssembly: ServicesAssembly!

    override func viewDidLoad() {
        super.viewDidLoad()

        let statisticsController = StatisticsModule.makeRoot()

        viewControllers = [
            statisticsController
        ]

        view.backgroundColor = .systemBackground
    }
}

