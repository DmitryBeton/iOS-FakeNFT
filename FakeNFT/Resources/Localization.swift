import Foundation

enum Localization {
    enum Profile {
        static func myNFT(count: Int) -> String {
            String.localizedStringWithFormat(
                NSLocalizedString("Profile.myNFT", comment: ""),
                count
            )
        }
        static func favourites(count: Int) -> String {
            String.localizedStringWithFormat(
                NSLocalizedString("Profile.favourites", comment: ""),
                count
            )
        }
    }
}

extension String {
    var localized: String {
        NSLocalizedString(self, comment: "")
    }
}
