import UIKit

protocol NetworkErrorView {
    
    /// Показать алерт сетевой ошибки
    /// - Parameter onRetry: Замыкание, вызывающееся при нажатии кнопки `Повторить`
    func showNetworkError(onRetry: (() -> Void)?)
    
}

extension NetworkErrorView where Self: UIViewController {
    
    func showNetworkError(onRetry: (() -> Void)?) {
        let alert = UIAlertController(
            title: Localization.ProfileAlert.loadError,
            message: nil,
            preferredStyle: .alert
        )
        let cancelAction = UIAlertAction(
            title: Localization.ProfileAlert.cancel,
            style: .cancel
        )
        let retryAction = UIAlertAction(
            title: Localization.ProfileAlert.retry,
            style: .default
        ) { _ in
            onRetry?()
        }
        alert.addAction(cancelAction)
        alert.addAction(retryAction)
        present(alert, animated: true)
    }
    
}
