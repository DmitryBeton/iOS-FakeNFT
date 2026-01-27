import Foundation

enum Localization {
    enum Profile {
        static let tabProfile = "Tab.profile".localized
        static let myNFT = "Profile.myNFT".localized
        static let favourites = "Profile.favourites".localized
        static let editName = "EditProfile.name".localized
        static let editDescription = "EditProfile.description".localized
        static let editWebsite = "EditProfile.website".localized
        static let saveEdit = "EditProfile.save".localized
    }
}

extension String {
    var localized: String {
        NSLocalizedString(self, comment: "")
    }
}
