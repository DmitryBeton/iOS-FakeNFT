import UIKit

final class ProfileViewController: UIViewController {
    
    // MARK: - Private Types
    
    private enum Menu {
        case myNFT
        case favourites
        
        func title(count: Int) -> String {
            switch self {
            case .myNFT: return Localization.Profile.myNFT(count: count)
            case .favourites: return Localization.Profile.favourites(count: count)
            }
        }
    }
    
    
    
}
