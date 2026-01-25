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

    }
    
}

extension String {
    var localized: String {
        NSLocalizedString(self, comment: "")
    }
}
