import UIKit

enum AppError: Error {
    case networkOffline
    case cartLoadFailed
    case cartDeleteFailed
    case cartAddFailed
    case paymentFailed
    case currencyNotSelected
    case currenciesLoadFailed
    case server(code: Int)
    case unknown(message: String)
}

struct ErrorPresentationModel {
    let title: String
    let message: String?
    let primaryActionTitle: String
    let secondaryActionTitle: String?
}

protocol ErrorPresenting: AnyObject {
    func present(model: ErrorPresentationModel, primaryAction: @escaping () -> Void)
    func present(error: AppError, retryAction: (() -> Void)?)
    func presentInfo(title: String, message: String)
    func presentRetry(title: String, message: String?, retryAction: @escaping () -> Void)
}

final class ErrorPresenter: ErrorPresenting {
    private weak var viewController: UIViewController?

    init(viewController: UIViewController) {
        self.viewController = viewController
    }

    func present(model: ErrorPresentationModel, primaryAction: @escaping () -> Void) {
        guard let viewController else { return }
        let alert = UIAlertController(title: model.title, message: model.message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: model.primaryActionTitle, style: .default) { _ in
            primaryAction()
        })
        if let secondaryActionTitle = model.secondaryActionTitle {
            alert.addAction(UIAlertAction(title: secondaryActionTitle, style: .cancel))
        }
        viewController.present(alert, animated: true)
    }

    func present(error: AppError, retryAction: (() -> Void)?) {
        let model = makeModel(for: error, hasRetryAction: retryAction != nil)
        present(model: model) {
            retryAction?()
        }
    }

    func presentInfo(title: String, message: String) {
        present(
            model: ErrorPresentationModel(
                title: title,
                message: message,
                primaryActionTitle: Localization.Cart.close.localized,
                secondaryActionTitle: nil
            ),
            primaryAction: {}
        )
    }

    func presentRetry(title: String, message: String?, retryAction: @escaping () -> Void) {
        present(
            model: ErrorPresentationModel(
                title: title,
                message: message,
                primaryActionTitle: Localization.Payment.retry.localized,
                secondaryActionTitle: Localization.Payment.cancel.localized
            )
        ) {
            retryAction()
        }
    }
}

private extension ErrorPresenter {
    func makeModel(for error: AppError, hasRetryAction: Bool) -> ErrorPresentationModel {
        let genericErrorTitle = NSLocalizedString("Error.title", comment: "")
        switch error {
        case .networkOffline:
            return ErrorPresentationModel(
                title: Localization.Payment.noInternet.localized,
                message: Localization.Payment.noInternetMessage.localized,
                primaryActionTitle: hasRetryAction ? Localization.Payment.retry.localized : Localization.Cart.close.localized,
                secondaryActionTitle: hasRetryAction ? Localization.Payment.cancel.localized : nil
            )
        case .cartLoadFailed:
            return ErrorPresentationModel(
                title: Localization.Cart.emptyStateMessage.localized,
                message: Localization.Cart.loadError.localized,
                primaryActionTitle: hasRetryAction ? Localization.Payment.retry.localized : Localization.Cart.close.localized,
                secondaryActionTitle: hasRetryAction ? Localization.Payment.cancel.localized : nil
            )
        case .cartDeleteFailed:
            return ErrorPresentationModel(
                title: Localization.Cart.emptyStateMessage.localized,
                message: Localization.Cart.deleteError.localized,
                primaryActionTitle: Localization.Cart.close.localized,
                secondaryActionTitle: nil
            )
        case .cartAddFailed:
            return ErrorPresentationModel(
                title: Localization.Cart.emptyStateMessage.localized,
                message: Localization.Cart.addError.localized,
                primaryActionTitle: Localization.Cart.close.localized,
                secondaryActionTitle: nil
            )
        case .paymentFailed:
            return ErrorPresentationModel(
                title: Localization.Payment.payErrorTitle.localized,
                message: nil,
                primaryActionTitle: hasRetryAction ? Localization.Payment.retry.localized : Localization.Cart.close.localized,
                secondaryActionTitle: hasRetryAction ? Localization.Payment.cancel.localized : nil
            )
        case .currencyNotSelected:
            return ErrorPresentationModel(
                title: Localization.Payment.payErrorTitle.localized,
                message: Localization.Payment.currencyNotSelected.localized,
                primaryActionTitle: hasRetryAction ? Localization.Payment.retry.localized : Localization.Cart.close.localized,
                secondaryActionTitle: hasRetryAction ? Localization.Payment.cancel.localized : nil
            )
        case .currenciesLoadFailed:
            return ErrorPresentationModel(
                title: Localization.Payment.currencyLoadErrorTitle.localized,
                message: nil,
                primaryActionTitle: hasRetryAction ? Localization.Payment.retry.localized : Localization.Cart.close.localized,
                secondaryActionTitle: hasRetryAction ? Localization.Payment.cancel.localized : nil
            )
        case .server(let code):
            return ErrorPresentationModel(
                title: String(format: Localization.Payment.serverErrorWithCode.localized, code),
                message: nil,
                primaryActionTitle: hasRetryAction ? Localization.Payment.retry.localized : Localization.Cart.close.localized,
                secondaryActionTitle: hasRetryAction ? Localization.Payment.cancel.localized : nil
            )
        case .unknown(let message):
            return ErrorPresentationModel(
                title: genericErrorTitle,
                message: message,
                primaryActionTitle: hasRetryAction ? Localization.Payment.retry.localized : Localization.Cart.close.localized,
                secondaryActionTitle: hasRetryAction ? Localization.Payment.cancel.localized : nil
            )
        }
    }
}

extension PaymentViewController {
    func showRetryAlert(title: String, message: String?, retryAction: @escaping () -> Void) {
        Self.logger.warning("[\(LogTimestamp.current(), privacy: .public)] Showing retry alert. title=\(title)")
        errorPresenter.presentRetry(title: title, message: message) {
            Self.logger.info("[\(LogTimestamp.current(), privacy: .public)] Retry tapped on alert")
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
        Self.logger.debug("[\(LogTimestamp.current(), privacy: .public)] Applied navigation title style")
    }

    func clearSelectionAndDisablePay() {
        collection.indexPathsForSelectedItems?.forEach { indexPath in
            collection.deselectItem(at: indexPath, animated: false)
        }
        paymentFooterView.isPayEnabled = false
        Self.logger.debug("[\(LogTimestamp.current(), privacy: .public)] Cleared selection and disabled pay")
    }
}
