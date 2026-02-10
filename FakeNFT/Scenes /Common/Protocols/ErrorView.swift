import UIKit

struct ErrorModel {
    let message: String
    let actionText: String
    let action: () -> Void
}

/// Базовый контракт отображения пользовательской ошибки на экране.
///
/// Используется View-слоями для единообразного показа alert-ошибок.
protocol ErrorView {
    /// Показывает ошибку по переданной модели.
    ///
    /// - Parameter model: Сообщение, текст action-кнопки и обработчик действия.
    func showError(_ model: ErrorModel)
}

extension ErrorView where Self: UIViewController {
    /// Реализация по умолчанию: системный `UIAlertController` с одной кнопкой действия.
    func showError(_ model: ErrorModel) {
        let title = NSLocalizedString("Error.title", comment: "")
        let alert = UIAlertController(
            title: title,
            message: model.message,
            preferredStyle: .alert
        )
        let action = UIAlertAction(title: model.actionText, style: UIAlertAction.Style.default) {_ in
            model.action()
        }
        alert.addAction(action)
        present(alert, animated: true)
    }
}
