import UIKit

extension PaymentViewController {
    func showRetryAlert(title: String, message: String?, retryAction: @escaping () -> Void) {
        Self.logger.warning("Showing retry alert. title=\(title)")
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)

        alert.addAction(UIAlertAction(title: PaymentViewConstants.Text.retry, style: .default) { _ in
            Self.logger.info("Retry tapped on alert")
            retryAction()
        })
        alert.addAction(UIAlertAction(title: PaymentViewConstants.Text.cancel, style: .cancel))

        present(alert, animated: true)
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
