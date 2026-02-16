import UIKit

final class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    var window: UIWindow?

    private let servicesAssembly = ServicesAssembly(
        networkClient: DefaultNetworkClient(),
        nftStorage: NftStorageImpl(),
        profileStorage: ProfileStorage(),
        myNftStorage: ProfileNftStorage(),
        favouritesStorage: ProfileNftStorage()
    )

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let windowScene = scene as? UIWindowScene else { return }
<<<<<<< HEAD

        let window = UIWindow(windowScene: windowScene)
        window.rootViewController = TabBarController(servicesAssembly: servicesAssembly)
        self.window = window
        window.makeKeyAndVisible()
=======
        
        let window = UIWindow(windowScene: windowScene)
        
        let hasSeenOnboarding = UserDefaults.standard.bool(forKey: "hasSeenOnboarding")
        
        if hasSeenOnboarding {
            showMainScreen(in: window)
        } else {
            showOnboarding(in: window)
        }
        
        window.makeKeyAndVisible()
        self.window = window
    }
    
    private func showOnboarding(in window: UIWindow) {
        let onboardingVC = OnboardingViewController()
        onboardingVC.onComplete = { [weak self] in
            UserDefaults.standard.set(true, forKey: "hasSeenOnboarding")
            self?.showMainScreen(in: window)
        }
        window.rootViewController = onboardingVC
    }
    
    private func showMainScreen(in window: UIWindow) {
        let tabBarController = TabBarController(servicesAssembly: servicesAssembly)
        window.rootViewController = tabBarController
>>>>>>> develop
    }
}

