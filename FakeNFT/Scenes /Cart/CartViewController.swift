//
//  CartViewController.swift
//  FakeNFT
//
//  Created by Дмитрий Чалов on 24.01.2026.
//

import UIKit
import OSLog

final class CartViewController: UIViewController {

    static let logger = Logger(subsystem: "com.fakenft.app", category: "CartViewController")

    // MARK: - Dependencies
    let viewModel: CartViewModelProtocol
    let servicesAssembly: ServicesAssembly

    // MARK: - State
    var isNavigatingToPayment = false

    // MARK: - UI Elements
    let refreshControl: UIRefreshControl = {
        let control = UIRefreshControl()
        control.tintColor = UIColor(resource: .nftBlack)
        return control
    }()

    let tableView: UITableView = {
        let tableView = UITableView()
        tableView.allowsSelection = false
        tableView.register(CartItemViewCell.self)
        tableView.estimatedRowHeight = 140
        tableView.rowHeight = UITableView.automaticDimension
        tableView.showsVerticalScrollIndicator = false
        tableView.separatorStyle = .none
        tableView.backgroundColor = .clear
        return tableView
    }()

    let orderSummaryView = OrderSummaryView()

    let emptyStateLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.bodyBold
        label.textAlignment = .center
        label.textColor = UIColor(resource: .nftBlack)
        label.text = Localization.Cart.emptyStateMessage.localized
        return label
    }()

    lazy var sortButton: UIBarButtonItem = {
        let sortButton = UIBarButtonItem(
            image: UIImage(resource: .sortIcon),
            style: .plain,
            target: self,
            action: #selector(sortButtonTapped)
        )
        sortButton.tintColor = UIColor(resource: .nftBlack)
        sortButton.accessibilityLabel = Localization.Cart.sort.localized
        return sortButton
    }()

    // MARK: - Initialization
    init(servicesAssembly: ServicesAssembly) {
        self.servicesAssembly = servicesAssembly
        self.viewModel = CartViewModel(service: servicesAssembly.cartService)
        super.init(nibName: nil, bundle: nil)
    }

    @available(*, unavailable)
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        fatalError("init(nibName:bundle:) is unavailable, use init(servicesAssembly:) instead")
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        nil
    }

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        Self.logger.debug("viewDidLoad")
        AnalyticsService.shared.track(.screenOpened(name: "cart"))

        setupUI()
        setupBindings()
        viewModel.loadItems()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        isNavigatingToPayment = false
        orderSummaryView.isUserInteractionEnabled = true
    }
}

// MARK: - Setup
private extension CartViewController {
    func setupUI() {
        view.backgroundColor = UIColor(resource: .nftWhite)
        configureTableView()

        [tableView, orderSummaryView, emptyStateLabel].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            view.addSubview($0)
        }

        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: orderSummaryView.topAnchor),

            orderSummaryView.heightAnchor.constraint(equalToConstant: 76),
            orderSummaryView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            orderSummaryView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            orderSummaryView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),

            emptyStateLabel.centerYAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerYAnchor),
            emptyStateLabel.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 16),
            emptyStateLabel.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -16)
        ])
    }

    func configureTableView() {
        tableView.dataSource = self
        tableView.delegate = self
        tableView.accessibilityIdentifier = "cart_table"
        refreshControl.addTarget(self, action: #selector(refreshPulled), for: .valueChanged)
        tableView.refreshControl = refreshControl
    }
}
