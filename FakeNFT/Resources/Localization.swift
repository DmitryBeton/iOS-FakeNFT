import Foundation

enum Localization {
    enum Catalog {
        static let catalog = "catalog"
        static let sortBy = "sort_by"
        static let sortByName = "name"
        static let sortByNumberOfNFTs = "number_of_NFTs"
        static let cancel = "cancel"
    }

    enum Profile {
        static let tabProfile = "Tab.profile".localized
        static let myNft = "Profile.myNFT".localized
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
        static let retry = "ProfileAlert.retry".localized
    }

    enum MyNft {
        static let title = "MyNFT.title".localized
        static let empty = "MyNFT.empty".localized
        static let price = "MyNFT.price".localized
        static let sort = "MyNFT.sort".localized
        static let byPrice = "MyNFT.byPrice".localized
        static let byRating = "MyNFT.byRating".localized
        static let byName = "MyNFT.byName".localized
        static let close = "MyNFT.close".localized

        static func fromAuthor(_ author: String) -> String {
            String.localizedStringWithFormat(
                NSLocalizedString("MyNFT.fromAuthor", comment: ""),
                author
            )
        }
    }

    enum Favourites {
        static let title = "Favourites.title".localized
        static let empty = "Favourites.empty".localized
    }

    enum Cart {
        static let tabBarItemTitle = "Tab.cart"
        static let emptyStateMessage = "Main.cart.empty"
        static let filterByPrice = "Filter.cart.by_price"
        static let filterByRating = "Filter.cart.by_rating"
        static let filterByTitle = "Filter.cart.by_title"
        static let price = "Cell.Price"
        static let sort = "Alert.sort"
        static let close = "Alert.close"
        static let payButton = "Button.to_pay"
        static let searchPlaceholder = "Cart.search.placeholder"
        static let searchNoResults = "Cart.search.no_results"
        static let loadError = "Cart.error.load"
        static let deleteError = "Cart.error.delete"
        static let addError = "Cart.error.add"
        static let countFormat = "Cart.count.nft_format"
        static let priceEthFormat = "Cart.price.eth_format"
        static let confirmationOfDeletion = "Delete.Alert.delete.confirmation"
        static let backButton = "Delete.Alert.cancel"
        static let deleteButton = "Delete.Alert.delete"
    }

    enum Payment {
        static let navTitle = "Payment.navigation_title"
        static let currencyLoadErrorTitle = "Payment.error.currency.load"
        static let payErrorTitle = "Payment.error.pay"
        static let retry = "Payment.retry"
        static let cancel = "Payment.cancel"
        static let successMessage = "Payment.success"
        static let backToCart = "Payment.back_to_cart"
        static let agreementPrefix = "Payment.agreement_prefix"
        static let agreementLink = "Payment.agreement_link"
        static let payButton = "Payment.pay"
        static let noInternet = "Payment.error.no_internet"
        static let noInternetMessage = "Payment.error.no_internet.message"
        static let currencyNotSelected = "Payment.error.currency_not_selected"
        static let serverErrorWithCode = "Payment.error.server_with_code"
    }
}

extension String {
    var localized: String {
        NSLocalizedString(self, comment: "")
    }
}
