//
//  CartViewController+Rendering.swift
//  FakeNFT
//
//  Created by Дмитрий Чалов on 24.01.2026.
//

import UIKit

// MARK: - Bindings
extension CartViewController {
    func setupBindings() {
        bindViewModel()
        bindOrderSummary()
    }

    func loadItemsOrShowOfflineAlert() {
        guard !connectivity.isOfflineNow() else {
            Self.logger.warning("Cart load blocked: no internet connection")
            showNoInternetAlert()
            finishRefreshingIfNeeded()
            return
        }
        viewModel.loadItems()
    }

    @objc func refreshPulled() {
        Self.logger.info("Pull-to-refresh triggered")
        AnalyticsService.shared.track(.buttonTapped(name: "pull_to_refresh", screen: "cart"))
        emptyStateLabel.isHidden = true
        loadItemsOrShowOfflineAlert()
    }

    @objc func sortButtonTapped() {
        AnalyticsService.shared.track(.buttonTapped(name: "sort", screen: "cart"))
        showSortOptionsMenu()
    }

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
        let alert = UIAlertController(
            title: Localization.Payment.noInternet.localized,
            message: Localization.Payment.noInternetMessage.localized,
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: Localization.Payment.retry.localized, style: .default) { [weak self] _ in
            self?.loadItemsOrShowOfflineAlert()
        })
        alert.addAction(UIAlertAction(title: Localization.Payment.cancel.localized, style: .cancel))
        present(alert, animated: true)
    }

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
        case .error(let message):
            renderError(message: message)
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
        Self.logger.debug("Rendering placeholders: \(items.count)")
        tableView.reloadData()
    }

    func renderLoaded(items: [UICartItem], total: Double) {
        UIBlockingProgressHUD.dismiss()
        let isSearchNoResults = items.isEmpty
        emptyStateLabel.text = isSearchNoResults ? "Ничего не найдено" : Localization.Cart.emptyStateMessage.localized
        emptyStateLabel.isHidden = !isSearchNoResults
        orderSummaryView.isHidden = false
        setSearchVisible(true)
        orderSummaryView.updateOrderSummary(count: viewModel.totalItemsCount, price: total)
        tableView.reloadData()
    }

    func renderEmpty() {
        UIBlockingProgressHUD.dismiss()
        emptyStateLabel.text = Localization.Cart.emptyStateMessage.localized
        emptyStateLabel.isHidden = false
        orderSummaryView.isHidden = true
        setSearchVisible(false)
        tableView.reloadData()
    }

    func renderError(message: String) {
        UIBlockingProgressHUD.dismiss()
        emptyStateLabel.text = Localization.Cart.emptyStateMessage.localized
        emptyStateLabel.isHidden = false
        orderSummaryView.isHidden = true
        setSearchVisible(false)
        tableView.reloadData()

        let alert = UIAlertController(
            title: Localization.Cart.emptyStateMessage.localized,
            message: message,
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: Localization.Cart.close.localized, style: .default))
        present(alert, animated: true)
    }

    func updateCartState() {
        let isEmpty = viewModel.isEmpty()
        Self.logger.debug("updateCartState. isEmpty=\(isEmpty)")

        emptyStateLabel.text = Localization.Cart.emptyStateMessage.localized
        emptyStateLabel.isHidden = !isEmpty
        orderSummaryView.isHidden = isEmpty
        setSearchVisible(!isEmpty)
    }
}

// MARK: - Actions
private extension CartViewController {
    func showSortOptionsMenu() {
        Self.logger.debug("Showing sort options menu")
        let alert = UIAlertController(
            title: Localization.Cart.sort.localized,
            message: nil,
            preferredStyle: .actionSheet
        )

        for option in SortOption.allCases {
            let action = UIAlertAction(title: option.localizedWord, style: .default) { [weak self] _ in
                Self.logger.info("Sort option selected: \(option.localizedWord)")
                AnalyticsService.shared.track(.buttonTapped(name: "sort_\(option.localizedWord)", screen: "cart"))
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
        Self.logger.info("Pay tapped from cart. Navigating to PaymentViewController")
        AnalyticsService.shared.track(.buttonTapped(name: "pay", screen: "cart"))
        AnalyticsService.shared.track(.checkoutStarted(itemCount: viewModel.totalItemsCount, totalPrice: viewModel.totalPrice))

        let paymentViewController = PaymentViewController(
            checkoutContext: .init(itemCount: viewModel.totalItemsCount, totalPrice: viewModel.totalPrice)
        )
        paymentViewController.hidesBottomBarWhenPushed = true
        navigationController?.pushViewController(paymentViewController, animated: true)
    }
}

// MARK: - Helpers
private extension CartViewController {
    func finishRefreshingIfNeeded() {
        if refreshControl.isRefreshing {
            refreshControl.endRefreshing()
        }
    }

    func logStateChange(_ state: CartViewState) {
        switch state {
        case .idle:
            Self.logger.debug("State changed -> idle")
        case .loading:
            Self.logger.debug("State changed -> loading")
        case .loadingPlaceholders(let items):
            Self.logger.debug("State changed -> loading placeholders. items=\(items.count)")
        case .loaded(let items, let total):
            Self.logger.info("State changed -> loaded. items=\(items.count), total=\(total, format: .fixed(precision: 2))")
        case .empty:
            Self.logger.info("State changed -> empty")
        case .error(let message):
            Self.logger.error("State changed -> error: \(message)")
        }
    }

}
