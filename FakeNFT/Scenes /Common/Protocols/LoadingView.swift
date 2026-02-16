import ProgressHUD
import UIKit

/// Базовый контракт управления индикатором загрузки в View-слое.
///
/// Ожидается, что конкретная View предоставляет `activityIndicator`
/// и использует методы протокола для управления его состоянием.
protocol LoadingView {
    /// Индикатор загрузки, привязанный к текущему экрану.
    var activityIndicator: UIActivityIndicatorView { get }
    /// Показывает состояние загрузки.
    func showLoading()
    /// Скрывает состояние загрузки.
    func hideLoading()
}

extension LoadingView {
    /// Реализация по умолчанию: запуск анимации индикатора.
    func showLoading() {
        activityIndicator.startAnimating()
    }

    /// Реализация по умолчанию: остановка анимации индикатора.
    func hideLoading() {
        activityIndicator.stopAnimating()
    }
}
