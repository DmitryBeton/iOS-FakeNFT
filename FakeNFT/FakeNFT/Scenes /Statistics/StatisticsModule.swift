import UIKit

enum StatisticsModule {

    static func makeRoot(servicesAssembly: ServicesAssembly) -> UIViewController {

        let viewModel = StatisticsViewModel(
            service: servicesAssembly.statisticsService
        )

        let viewController = StatisticsViewController(
            viewModel: viewModel,
            servicesAssembly: servicesAssembly
        )

        let nav = UINavigationController(rootViewController: viewController)
        nav.navigationBar.tintColor = .label
        return nav
    }
}

