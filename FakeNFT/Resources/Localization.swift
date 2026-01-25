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
        
        static let confirmationOfDeletion = "Delete.Alert.delete.confirmation"
        static let backButton = "Delete.Alert.cancel"
        static let deleteButton = "Delete.Alert.delete"
    }
    
}

extension String {
    var localized: String {
        NSLocalizedString(self, comment: "")
    }
}
