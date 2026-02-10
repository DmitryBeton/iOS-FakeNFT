//
//  CartViewController+Rendering.swift
//  FakeNFT
//
//  Created by Дмитрий Чалов on 24.01.2026.
//

import UIKit

// MARK: - Bindings
extension CartViewController {
    /// Подписывает экран на изменения VM и action-кнопок нижней панели.
    func setupBindings() {
        bindViewModel()
        bindOrderSummary()
    }

    /// Запускает загрузку корзины или показывает ошибку оффлайна.
    ///
    /// - Important: При отсутствии сети загрузка не стартует, чтобы не плодить
    ///   заведомо неуспешные запросы.
    func loadItemsOrShowOfflineAlert() {
        guard !connectivity.isOfflineNow() else {
            Self.logger.warning("[\(LogTimestamp.current(), privacy: .public)] Cart load blocked: no internet connection")
            showNoInternetAlert()
            finishRefreshingIfNeeded()
            return
        }
        viewModel.loadItems()
    }

    /// Обработчик pull-to-refresh.
    ///
    /// - Side effect: сбрасывает визуальное empty-состояние до получения нового state из VM.
    @objc func refreshPulled() {
        Self.logger.info("[\(LogTimestamp.current(), privacy: .public)] Pull-to-refresh triggered")
        AnalyticsService.shared.track(.buttonTapped(button: .pullToRefresh, screen: .cart))
        emptyStateLabel.isHidden = true
        loadItemsOrShowOfflineAlert()
    }

    @objc func sortButtonTapped() {
        AnalyticsService.shared.track(.buttonTapped(button: .sort, screen: .cart))
        showSortOptionsMenu()
    }

    /// Локальный поиск по уже загруженным элементам корзины.
    @objc func searchTextChanged(_ sender: UITextField) {
        viewModel.updateSearchQuery(sender.text ?? "")
    }

    @objc func handleBackgroundTap() {
        navigationController?.view.endEditing(true)
        view.window?.endEditing(true)
        view.endEditing(true)
    }

    func setSearchVisible(_ isVisible: Bool) {
        if !isVisible {
            if let text = searchTextField.text, !text.isEmpty {
                searchTextField.text = ""
                viewModel.updateSearchQuery("")
            }
            navigationItem.titleView = nil
            navigationItem.rightBarButtonItem = nil
            return
        }
        navigationItem.titleView = searchTitleContainer
        navigationItem.rightBarButtonItem = sortButton
    }
}

extension CartViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}

extension CartViewController: UIGestureRecognizerDelegate {
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        guard searchTextField.isFirstResponder else { return false }
        guard let touchedView = touch.view else { return false }

        if touchedView.isDescendant(of: searchTitleContainer) {
            return false
        }
        return true
    }

    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        true
    }
}

private extension CartViewController {
    func showNoInternetAlert() {
        errorPresenter.present(error: .networkOffline) { [weak self] in
            self?.loadItemsOrShowOfflineAlert()
        }
    }

    /// Подписывает UI на изменения состояния VM.
    ///
    /// - Important: Рендер всегда выполняется в main thread.
    func bindViewModel() {
        viewModel.onStateChange = { [weak self] state in
            guard let self else { return }
            DispatchQueue.main.async {
                self.finishRefreshingIfNeeded()
                self.logStateChange(state)
                self.render(state: state)
            }
        }
    }

    func bindOrderSummary() {
        orderSummaryView.onPayTapped = { [weak self] in
            self?.navigateToPaymentIfNeeded()
        }
    }
}

// MARK: - Render
private extension CartViewController {
    /// Рендерит одно из конечных состояний экрана корзины.
    func render(state: CartViewState) {
        switch state {
        case .idle:
            renderIdle()
        case .loading:
            renderLoading()
        case .loadingPlaceholders(let items):
            renderLoadingPlaceholders(items: items)
        case .loaded(let items, let total):
            renderLoaded(items: items, total: total)
        case .empty:
            renderEmpty()
        case .error(let error):
            renderError(error: error)
        }
    }

    func renderIdle() {
        updateCartState()
    }

    func renderLoading() {
        UIBlockingProgressHUD.show()
        emptyStateLabel.isHidden = true
        orderSummaryView.isHidden = true
        setSearchVisible(false)
    }

    func renderLoadingPlaceholders(items: [UICartItem]) {
        UIBlockingProgressHUD.dismiss()
        emptyStateLabel.isHidden = true
        orderSummaryView.isHidden = true
        setSearchVisible(false)
        Self.logger.debug("[\(LogTimestamp.current(), privacy: .public)] Rendering placeholders: \(items.count)")
        applyTableUpdates(with: items, animated: true)
    }

    func renderLoaded(items: [UICartItem], total: Double) {
        UIBlockingProgressHUD.dismiss()
        let isSearchNoResults = items.isEmpty
        emptyStateLabel.text = isSearchNoResults
        ? Localization.Cart.searchNoResults.localized
        : Localization.Cart.emptyStateMessage.localized
        emptyStateLabel.isHidden = !isSearchNoResults
        orderSummaryView.isHidden = false
        setSearchVisible(true)
        orderSummaryView.updateOrderSummary(count: viewModel.totalItemsCount, price: total)
        applyTableUpdates(with: items, animated: true)
    }

    func renderEmpty() {
        UIBlockingProgressHUD.dismiss()
        emptyStateLabel.text = Localization.Cart.emptyStateMessage.localized
        emptyStateLabel.isHidden = false
        orderSummaryView.isHidden = true
        setSearchVisible(false)
        renderedItemsSnapshot = []
        tableView.reloadData()
    }

    func renderError(error: AppError) {
        UIBlockingProgressHUD.dismiss()
        emptyStateLabel.text = Localization.Cart.emptyStateMessage.localized
        emptyStateLabel.isHidden = false
        orderSummaryView.isHidden = true
        setSearchVisible(false)
        renderedItemsSnapshot = []
        tableView.reloadData()
        let retryAction: (() -> Void)?
        switch error {
        case .networkOffline, .cartLoadFailed:
            retryAction = { [weak self] in self?.loadItemsOrShowOfflineAlert() }
        default:
            retryAction = nil
        }
        errorPresenter.present(error: error, retryAction: retryAction)
    }

    func updateCartState() {
        let isEmpty = viewModel.isEmpty()
        Self.logger.debug("[\(LogTimestamp.current(), privacy: .public)] updateCartState. isEmpty=\(isEmpty)")

        emptyStateLabel.text = Localization.Cart.emptyStateMessage.localized
        emptyStateLabel.isHidden = !isEmpty
        orderSummaryView.isHidden = isEmpty
        setSearchVisible(!isEmpty)
    }
}

// MARK: - Actions
private extension CartViewController {
    func showSortOptionsMenu() {
        Self.logger.debug("[\(LogTimestamp.current(), privacy: .public)] Showing sort options menu")
        let alert = UIAlertController(
            title: Localization.Cart.sort.localized,
            message: nil,
            preferredStyle: .actionSheet
        )

        for option in SortOption.allCases {
            let action = UIAlertAction(title: option.localizedWord, style: .default) { [weak self] _ in
                Self.logger.info("[\(LogTimestamp.current(), privacy: .public)] Sort option selected: \(option.localizedWord)")
                AnalyticsService.shared.track(.buttonTapped(button: .sortOption(name: option.localizedWord), screen: .cart))
                self?.viewModel.sortOption = option
            }
            alert.addAction(action)
        }

        alert.addAction(UIAlertAction(title: Localization.Cart.close.localized, style: .cancel))
        present(alert, animated: true)
    }

    func navigateToPaymentIfNeeded() {
        guard !isNavigatingToPayment else { return }

        isNavigatingToPayment = true
        orderSummaryView.isUserInteractionEnabled = false
        Self.logger.info("[\(LogTimestamp.current(), privacy: .public)] Pay tapped from cart. Navigating to PaymentViewController")
        AnalyticsService.shared.track(.buttonTapped(button: .pay, screen: .cart))
        AnalyticsService.shared.track(.checkoutStarted(itemCount: viewModel.totalItemsCount, totalPrice: viewModel.totalPrice))

        routeToPayment(checkoutContext: .init(itemCount: viewModel.totalItemsCount, totalPrice: viewModel.totalPrice))
    }
}

// MARK: - Helpers
private extension CartViewController {
    /// Применяет дифф-обновление таблицы без полного `reloadData`, где это безопасно.
    ///
    /// Почему такой алгоритм:
    /// - сначала считаем delete/insert/move по `id`, чтобы сохранить анимации и избежать наложений;
    /// - для хрупких переходов (например, в пустой список) используем fallback на `reloadData`.
    ///
    /// Ограничения:
    /// - метод должен вызываться на main thread;
    /// - `renderedItemsSnapshot` считается источником истины для предыдущего кадра UI.
    func applyTableUpdates(with items: [UICartItem], animated: Bool) {
        let newSnapshot = items.map(RenderedCartItem.init)
        let oldSnapshot = renderedItemsSnapshot
        renderedItemsSnapshot = newSnapshot

        guard animated else {
            tableView.reloadData()
            return
        }

        if oldSnapshot.isEmpty {
            tableView.reloadData()
            return
        }

        // Empty transitions are the most fragile for UITableView batch math.
        if newSnapshot.isEmpty {
            tableView.reloadData()
            return
        }

        let oldIndexByID = Dictionary(uniqueKeysWithValues: oldSnapshot.enumerated().map { ($0.element.id, $0.offset) })
        let newIndexByID = Dictionary(uniqueKeysWithValues: newSnapshot.enumerated().map { ($0.element.id, $0.offset) })

        let deletedRows = oldIndexByID
            .compactMap { id, oldIndex in newIndexByID[id] == nil ? IndexPath(row: oldIndex, section: 0) : nil }
            .sorted { $0.row > $1.row }

        let insertedRows = newIndexByID
            .compactMap { id, newIndex in oldIndexByID[id] == nil ? IndexPath(row: newIndex, section: 0) : nil }
            .sorted { $0.row < $1.row }

        let movedPairs: [(from: IndexPath, to: IndexPath)] = oldIndexByID.compactMap { id, oldIndex in
            guard let newIndex = newIndexByID[id], oldIndex != newIndex else { return nil }
            return (from: IndexPath(row: oldIndex, section: 0), to: IndexPath(row: newIndex, section: 0))
        }

        let changedRows = newSnapshot.enumerated().compactMap { index, item -> IndexPath? in
            guard let oldIndex = oldIndexByID[item.id] else { return nil }
            return oldSnapshot[oldIndex] == item ? nil : IndexPath(row: index, section: 0)
        }

        if deletedRows.isEmpty, insertedRows.isEmpty, movedPairs.isEmpty, changedRows.isEmpty {
            return
        }

        let expectedCount = oldSnapshot.count - deletedRows.count + insertedRows.count
        guard expectedCount == newSnapshot.count else {
            tableView.reloadData()
            return
        }

        tableView.performBatchUpdates {
            if !deletedRows.isEmpty {
                tableView.deleteRows(at: deletedRows, with: .fade)
            }

            if !insertedRows.isEmpty {
                tableView.insertRows(at: insertedRows, with: .fade)
            }

            for pair in movedPairs {
                tableView.moveRow(at: pair.from, to: pair.to)
            }
        } completion: { [weak self] _ in
            guard let self else { return }
            if !changedRows.isEmpty {
                self.tableView.reloadRows(at: changedRows, with: .none)
            }
        }
    }

    func finishRefreshingIfNeeded() {
        if refreshControl.isRefreshing {
            refreshControl.endRefreshing()
        }
    }

    func logStateChange(_ state: CartViewState) {
        switch state {
        case .idle:
            Self.logger.debug("[\(LogTimestamp.current(), privacy: .public)] State changed -> idle")
        case .loading:
            Self.logger.debug("[\(LogTimestamp.current(), privacy: .public)] State changed -> loading")
        case .loadingPlaceholders(let items):
            Self.logger.debug("[\(LogTimestamp.current(), privacy: .public)] State changed -> loading placeholders. items=\(items.count)")
        case .loaded(let items, let total):
            Self.logger.info("[\(LogTimestamp.current(), privacy: .public)] State changed -> loaded. items=\(items.count), total=\(total, format: .fixed(precision: 2))")
        case .empty:
            Self.logger.info("[\(LogTimestamp.current(), privacy: .public)] State changed -> empty")
        case .error(let error):
            Self.logger.error("[\(LogTimestamp.current(), privacy: .public)] State changed -> error: \(String(describing: error), privacy: .public)")
        }
    }

}
