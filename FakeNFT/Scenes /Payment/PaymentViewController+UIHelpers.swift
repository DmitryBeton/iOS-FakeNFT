import UIKit

protocol ErrorPresenting: AnyObject {
    func presentInfo(title: String, message: String)
    func presentRetry(title: String, message: String?, retryAction: @escaping () -> Void)
}

final class ErrorPresenter: ErrorPresenting {
    private weak var viewController: UIViewController?

    init(viewController: UIViewController) {
        self.viewController = viewController
    }

    func presentInfo(title: String, message: String) {
        guard let viewController else { return }
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: Localization.Cart.close.localized, style: .default))
        viewController.present(alert, animated: true)
    }

    func presentRetry(title: String, message: String?, retryAction: @escaping () -> Void) {
        guard let viewController else { return }
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: Localization.Payment.retry.localized, style: .default) { _ in
            retryAction()
        })
        alert.addAction(UIAlertAction(title: Localization.Payment.cancel.localized, style: .cancel))
        viewController.present(alert, animated: true)
    }
}

extension PaymentViewController {
    func showRetryAlert(title: String, message: String?, retryAction: @escaping () -> Void) {
        Self.logger.warning("Showing retry alert. title=\(title)")
        errorPresenter.presentRetry(title: title, message: message) {
            Self.logger.info("Retry tapped on alert")
            retryAction()
        }
    }

    func applyNavigationTitleStyle() {
        let paragraph = NSMutableParagraphStyle()
        paragraph.minimumLineHeight = 22
        paragraph.maximumLineHeight = 22
        paragraph.alignment = .center

        let attributes: [NSAttributedString.Key: Any] = [
            .font: UIFont.bodyBold,
            .paragraphStyle: paragraph,
            .kern: 0,
            .foregroundColor: UIColor(resource: .nftBlack)
        ]

        navigationController?.navigationBar.titleTextAttributes = attributes
        Self.logger.debug("Applied navigation title style")
    }

    func clearSelectionAndDisablePay() {
        collection.indexPathsForSelectedItems?.forEach { indexPath in
            collection.deselectItem(at: indexPath, animated: false)
        }
        paymentFooterView.isPayEnabled = false
        Self.logger.debug("Cleared selection and disabled pay")
    }
}
