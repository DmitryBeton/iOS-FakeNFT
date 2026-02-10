import Foundation

enum Localization {

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
