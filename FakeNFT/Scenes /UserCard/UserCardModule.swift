import UIKit

enum UserCardModule {
    static func make(userId: String, servicesAssembly: ServicesAssembly) -> UIViewController {
        let viewModel = UserCardViewModel(service: servicesAssembly.userService)
        let vc = UserCardViewController(viewModel: viewModel, servicesAssembly: servicesAssembly)
        vc.configure(userId: userId)
        return vc
    }
}

