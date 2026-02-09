import UIKit

enum UserCollectionModule {
    static func make(userId: String, nftCount: Int) -> UIViewController {
        UserCollectionViewController(userId: userId, nftCount: nftCount)
    }
}
