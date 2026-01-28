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
    enum ProfileAlert {
        static let profilePhoto = "ProfileAlert.profilePhoto".localized
        static let changePhoto = "ProfileAlert.changePhoto".localized
        static let deletePhoto = "ProfileAlert.deletePhoto".localized
        static let photoLink = "ProfileAlert.photoLink".localized
        static let cancel = "ProfileAlert.cancel".localized
        static let save = "ProfileAlert.save".localized
        static let wantToExit = "ProfileAlert.wantToExit".localized
        static let stay = "ProfileAlert.stay".localized
        static let exit = "ProfileAlert.exit".localized
    }
}

extension String {
    var localized: String {
        NSLocalizedString(self, comment: "")
    }
}
