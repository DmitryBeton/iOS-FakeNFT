import Foundation

enum Localization {
    enum Catalog {
        static let catalog = "catalog"
        static let sortBy = "sort_by"
        static let sortByName = "name"
        static let sortByNumberOfNFTs = "number_of_NFTs"
        static let cancel = "cancel"
    }
}

extension String {
    var localized: String {
        NSLocalizedString(self, comment: "")
    }
}
