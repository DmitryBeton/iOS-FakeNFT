//
//  PaymentViewController.swift
//  FakeNFT
//
//  Created by Дмитрий Чалов on 31.01.2026.
//

import UIKit
import OSLog

final class PaymentViewController: UIViewController {

    static let logger = Logger(subsystem: "com.fakenft.app", category: "PaymentViewController")

    // MARK: - Properties
    let viewModel: PaymentViewModelProtocol
    private let checkoutContext: CheckoutAnalyticsContext?
    var selectedCurrencyID: String?

    private let connectivity = ConnectivityService()
    lazy var errorPresenter: ErrorPresenting = ErrorPresenter(viewController: self)

    // MARK: - UI Elements
    let collection: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        let collection = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collection.backgroundColor = .clear
        collection.register(UICurrencyCollectionViewCell.self)
        collection.allowsMultipleSelection = false
        return collection
    }()

    let paymentFooterView = PaymentFooterView()

    // MARK: - Initialization
    init(
        viewModel: PaymentViewModelProtocol = PaymentViewModel(),
        checkoutContext: CheckoutAnalyticsContext? = nil
    ) {
        self.viewModel = viewModel
        self.checkoutContext = checkoutContext
        super.init(nibName: nil, bundle: nil)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        nil
    }

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        Self.logger.debug("[\(LogTimestamp.current(), privacy: .public)] viewDidLoad")
        AnalyticsService.shared.track(.screenOpened(screen: .payment))
        navigationItem.title = PaymentViewConstants.Text.navTitle

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
            paymentFooterView.heightAnchor.constraint(equalToConstant: PaymentViewConstants.Layout.footerHeight)
        ])
    }

    private func setupBindings() {
        paymentFooterView.onPayTapped = { [weak self] in
            Self.logger.info("[\(LogTimestamp.current(), privacy: .public)] Pay tapped on Payment screen")
            AnalyticsService.shared.track(.buttonTapped(button: .pay, screen: .payment))
            self?.startPayment()
        }

        paymentFooterView.onAgreementTapped = { [weak self] in
            Self.logger.info("[\(LogTimestamp.current(), privacy: .public)] Agreement tapped. Opening: \(PaymentViewConstants.Text.agreementURL)")
            AnalyticsService.shared.track(.buttonTapped(button: .agreement, screen: .payment))
            let vc = AgreementWebViewController(urlString: PaymentViewConstants.Text.agreementURL)
            self?.navigationController?.pushViewController(vc, animated: true)
        }

        viewModel.onStateChange = { [weak self] state in
            guard let self else { return }
            DispatchQueue.main.async {
                switch state {
                case .idle:
                    Self.logger.debug("[\(LogTimestamp.current(), privacy: .public)] State -> idle")
                case .loadingCurrencies:
                    Self.logger.debug("[\(LogTimestamp.current(), privacy: .public)] State -> loadingCurrencies")
                case .currenciesLoaded(let items):
                    Self.logger.info("[\(LogTimestamp.current(), privacy: .public)] State -> currenciesLoaded. count=\(items.count)")
                case .empty:
                    Self.logger.info("[\(LogTimestamp.current(), privacy: .public)] State -> empty")
                case .paying:
                    Self.logger.info("[\(LogTimestamp.current(), privacy: .public)] State -> paying")
                case .paid:
                    Self.logger.info("[\(LogTimestamp.current(), privacy: .public)] State -> paid")
                case .error(let error, let recovery):
                    Self.logger.error("[\(LogTimestamp.current(), privacy: .public)] State -> error: \(String(describing: error), privacy: .public), recovery=\(String(describing: recovery), privacy: .public)")
                }
                self.render(state: state)
            }
        }
    }

    // MARK: - Private Methods
    private func render(state: PaymentViewState) {
        Self.logger.debug("[\(LogTimestamp.current(), privacy: .public)] render(state:) called")
        switch state {
        case .idle:
            paymentFooterView.isPayEnabled = false
        case .loadingCurrencies:
            UIBlockingProgressHUD.show()
            paymentFooterView.isPayEnabled = false
        case .currenciesLoaded(let items):
            UIBlockingProgressHUD.dismiss()
            collection.reloadData()
            Self.logger.debug("[\(LogTimestamp.current(), privacy: .public)] Collection reloaded with currencies")
            paymentFooterView.isPayEnabled = false
            if items.isEmpty {
                errorPresenter.present(error: .currenciesLoadFailed) { [weak self] in
                    self?.startLoadCurrency()
                }
            }
        case .empty:
            UIBlockingProgressHUD.dismiss()
            collection.reloadData()
            paymentFooterView.isPayEnabled = false
        case .paying:
            UIBlockingProgressHUD.show()
        case .paid:
            UIBlockingProgressHUD.dismiss()
            if let checkoutContext {
                AnalyticsService.shared.track(
                    .purchaseCompleted(
                        itemCount: checkoutContext.itemCount,
                        totalPrice: checkoutContext.totalPrice,
                        currencyID: selectedCurrencyID
                    )
                )
            }
            let successVC = PaymentSuccessViewController()
            successVC.navigationItem.hidesBackButton = true
            successVC.onBackToCartTapped = { [weak self] in
                self?.navigationController?.popToViewController(ofType: CartViewController.self, animated: true)
            }
            navigationController?.pushViewController(successVC, animated: true)
        case .error(let error, let recovery):
            Self.logger.error("[\(LogTimestamp.current(), privacy: .public)] Render error state with message: \(String(describing: error), privacy: .public)")
            UIBlockingProgressHUD.dismiss()
            AnalyticsService.shared.track(.purchaseFailed(reason: String(describing: error), screen: .payment))
            presentPaymentError(error, recovery: recovery)
        }
    }

    private func startPayment() {
        guard !connectivity.isOfflineNow() else {
            Self.logger.warning("[\(LogTimestamp.current(), privacy: .public)] Payment blocked: no internet connection")
            errorPresenter.present(error: .networkOffline) { [weak self] in
                self?.startPayment()
            }
            return
        }

        Self.logger.info("[\(LogTimestamp.current(), privacy: .public)] Starting payment...")
        viewModel.pay { [weak self] result in
            guard let self else { return }
            switch result {
            case .success:
                Self.logger.info("[\(LogTimestamp.current(), privacy: .public)] Payment completion returned success")
                break // The .paid state will be rendered by onStateChange
            case .failure:
                Self.logger.error("[\(LogTimestamp.current(), privacy: .public)] Payment completion returned failure")
                break // The .error state will be rendered by onStateChange
            }
        }
    }

    private func startLoadCurrency() {
        guard !connectivity.isOfflineNow() else {
            Self.logger.warning("[\(LogTimestamp.current(), privacy: .public)] Currency load blocked: no internet connection")
            errorPresenter.present(error: .networkOffline) { [weak self] in
                self?.startLoadCurrency()
            }
            return
        }

        Self.logger.info("[\(LogTimestamp.current(), privacy: .public)] Loading currencies requested")
        AnalyticsService.shared.track(.buttonTapped(button: .loadCurrencies, screen: .payment))
        viewModel.loadItems()
    }

}

private extension PaymentViewController {
    func presentPaymentError(_ error: AppError, recovery: PaymentRecoveryAction) {
        let retryAction: (() -> Void)?
        switch recovery {
        case .retryLoadCurrencies:
            retryAction = { [weak self] in self?.startLoadCurrency() }
        case .retryPayment:
            retryAction = { [weak self] in self?.startPayment() }
        case .clearSelection:
            retryAction = { [weak self] in self?.clearSelectionAndDisablePay() }
        case .none:
            retryAction = nil
        }
        errorPresenter.present(error: error, retryAction: retryAction)
    }
}
