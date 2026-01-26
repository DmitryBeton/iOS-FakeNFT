import Foundation

enum Localization {
    enum Profile {
        static let tabProfile = "Tab.profile".localized
        static let myNFT = "Profile.myNFT".localized
        static let favourites = "Profile.favourites".localized
    }
}

extension String {
    var localized: String {
        NSLocalizedString(self, comment: "")
    }
}
