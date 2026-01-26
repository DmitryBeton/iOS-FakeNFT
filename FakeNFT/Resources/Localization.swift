import Foundation

enum Localization {
    
}

extension String {
    var localized: String {
        NSLocalizedString(self, comment: "")
    }
}
