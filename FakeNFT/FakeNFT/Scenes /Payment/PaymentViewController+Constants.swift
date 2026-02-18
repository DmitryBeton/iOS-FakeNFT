import UIKit

struct CheckoutAnalyticsContext {
    let itemCount: Int
    let totalPrice: Double
}

enum PaymentViewConstants {
    enum Text {
        static let navTitle = Localization.Payment.navTitle.localized
        static let agreementURL = "https://yandex.ru/legal/practicum_termsofuse"
        static let currencyLoadErrorTitle = Localization.Payment.currencyLoadErrorTitle.localized
        static let payErrorTitle = Localization.Payment.payErrorTitle.localized
        static let retry = Localization.Payment.retry.localized
        static let cancel = Localization.Payment.cancel.localized
    }

    enum Layout {
        static let sectionInset = UIEdgeInsets(top: 16, left: 16, bottom: 16, right: 16)
        static let minimumLineSpacing: CGFloat = 7
        static let minimumInteritemSpacing: CGFloat = 7
        static let itemsPerRow: CGFloat = 2
        static let collectionHorizontalPadding: CGFloat = 16
        static let itemHeightToWidthRatio: CGFloat = 0.2738
        static let footerHeight: CGFloat = 186
    }
}
