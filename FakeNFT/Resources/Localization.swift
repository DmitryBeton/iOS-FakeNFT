import Foundation

enum Localization {
    
    enum Cart {
        static let tabBarItemTitle = "Tab.cart"
    }
    
}

extension String {
    var localized: String {
        NSLocalizedString(self, comment: "")
    }
}
