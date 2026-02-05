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
        static let loadError = "ProfileAlert.loadError".localized
        static let updateError = "ProfileAlert.updateError".localized
        static let retry = "ProfileAlert.retry".localized
    }
    enum MyNFT {
        static let title = "MyNFT.title".localized
        static let empty = "MyNFT.empty".localized
        static let price = "MyNFT.price".localized
        
        static func fromAuthor(_ author: String) -> String {
            String.localizedStringWithFormat(
                NSLocalizedString("MyNFT.fromAuthor", comment: ""),
                author
            )
        }
    }
}

extension String {
    var localized: String {
        NSLocalizedString(self, comment: "")
    }
}
