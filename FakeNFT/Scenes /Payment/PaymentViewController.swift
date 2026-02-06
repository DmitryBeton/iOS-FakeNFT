//
//  PaymentViewController.swift
//  FakeNFT
//
//  Created by Дмитрий Чалов on 31.01.2026.
//

import UIKit

final class PaymentViewController: UIViewController {

    // MARK: - Properties
    private let viewModel: PaymentViewModelProtocol

    private let connectivity = ConnectivityService()

    // MARK: - UI Elements
    private let collection: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        let collection = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collection.backgroundColor = .clear
        collection.register(UICurrencyCollectionViewCell.self)
        collection.allowsMultipleSelection = false
        return collection
    }()

    private let paymentFooterView = PaymentFooterView()

    // MARK: - Initialization
    init(viewModel: PaymentViewModelProtocol = PaymentViewModel()) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        nil
    }

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = Constants.Text.navTitle

        connectivity.start()

        setupUI()
        applyNavigationTitleStyle()
        setupBindings()

        startLoadCurrency()

        paymentFooterView.isPayEnabled = false
    }

    deinit {
        connectivity.stop()
    }

    // MARK: - Setup
    private func setupUI() {
        view.backgroundColor = UIColor(resource: .nftWhite)

        collection.delegate = self
        collection.dataSource = self

        view.addSubview(collection)
        view.addSubview(paymentFooterView)

        collection.translatesAutoresizingMaskIntoConstraints = false
        paymentFooterView.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            collection.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            collection.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            collection.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            collection.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),

            paymentFooterView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            paymentFooterView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            paymentFooterView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            paymentFooterView.heightAnchor.constraint(equalToConstant: Constants.Layout.footerHeight)
        ])
    }

    private func setupBindings() {
        paymentFooterView.onPayTapped = { [weak self] in
            self?.startPayment()
        }

        paymentFooterView.onAgreementTapped = { [weak self] in
            let vc = AgreementWebViewController(urlString: Constants.Text.agreementURL)
            self?.navigationController?.pushViewController(vc, animated: true)
        }

        viewModel.onStateChange = { [weak self] state in
            guard let self else { return }
            DispatchQueue.main.async {
                self.render(state: state)
            }
        }
    }

    // MARK: - Private Methods
    private func render(state: PaymentViewState) {
        switch state {
        case .idle:
            paymentFooterView.isPayEnabled = false
        case .loadingCurrencies:
            UIBlockingProgressHUD.show()
            paymentFooterView.isPayEnabled = false
        case .currenciesLoaded(let items):
            UIBlockingProgressHUD.dismiss()
            collection.reloadData()
            paymentFooterView.isPayEnabled = false
            if items.isEmpty {
                showRetryAlert(title: Constants.Text.currencyLoadErrorTitle, message: nil) { [weak self] in self?.startLoadCurrency() }
            }
        case .empty:
            UIBlockingProgressHUD.dismiss()
            collection.reloadData()
            paymentFooterView.isPayEnabled = false
        case .paying:
            UIBlockingProgressHUD.show()
        case .paid:
            UIBlockingProgressHUD.dismiss()
            let successVC = PaymentSuccessViewController()
            successVC.navigationItem.hidesBackButton = true
            successVC.onBackToCartTapped = { [weak self] in
                self?.navigationController?.popToViewController(ofType: CartViewController.self, animated: true)
            }
            navigationController?.pushViewController(successVC, animated: true)
        case .error(let message):
            UIBlockingProgressHUD.dismiss()
            let isOffline = connectivity.isOfflineNow()
            let title = isOffline ? Localization.Payment.noInternet.localized : message
            let msg = isOffline ? Localization.Payment.noInternetMessage.localized : nil
            showRetryAlert(title: title, message: msg) { [weak self] in self?.startLoadCurrency() }
        }
    }

    private func startPayment() {
        viewModel.pay { [weak self] result in
            guard let self else { return }
            switch result {
            case .success:
                break // The .paid state will be rendered by onStateChange
            case .failure:
                break // The .error state will be rendered by onStateChange
            }
        }
    }

    private func startLoadCurrency() {
        viewModel.loadItems()
    }

    // MARK: - Generic alerts
    private func showRetryAlert(title: String, message: String?, retryAction: @escaping () -> Void) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)

        alert.addAction(UIAlertAction(title: Constants.Text.retry, style: .default) { _ in
            retryAction()
        })
        alert.addAction(UIAlertAction(title: Constants.Text.cancel, style: .cancel))

        present(alert, animated: true)
    }

    private func applyNavigationTitleStyle() {
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
    }

    private func clearSelectionAndDisablePay() {
        collection.indexPathsForSelectedItems?.forEach { indexPath in
            collection.deselectItem(at: indexPath, animated: false)
        }
        paymentFooterView.isPayEnabled = false
    }
}

extension PaymentViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        viewModel.itemsCount
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell: UICurrencyCollectionViewCell = collection.dequeueReusableCell(indexPath: indexPath)

        if let uiCurrency = viewModel.getUICurrency(at: indexPath.row) {
            cell.configure(currency: uiCurrency)
        }

        return cell
    }
}

extension PaymentViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {

        let padding = Constants.Layout.collectionHorizontalPadding
        let spacing = Constants.Layout.minimumInteritemSpacing
        let itemsPerRow = Constants.Layout.itemsPerRow

        let availableWidth = collectionView.frame.width - padding * 2 - spacing * (itemsPerRow - 1)
        let widthPerItem = availableWidth / itemsPerRow
        let height = widthPerItem * Constants.Layout.itemHeightToWidthRatio

        return CGSize(width: widthPerItem, height: height)
    }

    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        insetForSectionAt section: Int) -> UIEdgeInsets {
        Constants.Layout.sectionInset
    }

    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        Constants.Layout.minimumLineSpacing
    }

    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        Constants.Layout.minimumInteritemSpacing
    }
}

// MARK: - Selection handling
extension PaymentViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        paymentFooterView.isPayEnabled = true
    }

    func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        let hasSelection = !(collectionView.indexPathsForSelectedItems?.isEmpty ?? true)
        paymentFooterView.isPayEnabled = hasSelection
    }
}

private enum Constants {
    enum Text {
        static let navTitle = Localization.Payment.navTitle.localized
        static let agreementURL = "https://yandex.ru/legal/practicum_termsofuse"
        static let currencyLoadErrorTitle = Localization.Payment.currencyLoadErrorTitle.localized
        static let payErrorTitle = Localization.Payment.payErrorTitle.localized
        static let retry = Localization.Payment.retry.localized
        static let cancel = Localization.Payment.cancel.localized
    }
    enum Layout {
        // Collection layout
        static let sectionInset = UIEdgeInsets(top: 16, left: 16, bottom: 16, right: 16)
        static let minimumLineSpacing: CGFloat = 7
        static let minimumInteritemSpacing: CGFloat = 7
        static let itemsPerRow: CGFloat = 2
        static let collectionHorizontalPadding: CGFloat = 16
        static let itemHeightToWidthRatio: CGFloat = 0.2738

        // Footer
        static let footerHeight: CGFloat = 186
    }
}
