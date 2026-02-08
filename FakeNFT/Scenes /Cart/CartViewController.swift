//
//  CartViewController.swift
//  FakeNFT
//
//  Created by Дмитрий Чалов on 24.01.2026.
//

import UIKit
import OSLog

final class CartViewController: UIViewController {

    private static let logger = Logger(subsystem: "com.fakenft.app", category: "CartViewController")

    private var isNavigatingToPayment = false

    // MARK: - Properties
    private let viewModel: CartViewModelProtocol
    let servicesAssembly: ServicesAssembly

    // MARK: - UI Elements
    private let refreshControl: UIRefreshControl = {
        let control = UIRefreshControl()
        control.tintColor = UIColor(resource: .nftBlack)
        return control
    }()

    private let tableView: UITableView = {
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

    private let orderSummaryView: OrderSummaryView = {
        let view = OrderSummaryView()
        return view
    }()

    private let emptyStateLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.bodyBold
        label.textAlignment = .center
        label.textColor = UIColor(resource: .nftBlack)
        label.text = Localization.Cart.emptyStateMessage.localized
        return label
    }()

    private lazy var sortButton: UIBarButtonItem = {
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
        self.viewModel = CartViewModel()
        super.init(nibName: nil, bundle: nil)
    }

    @available(*, unavailable)
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        fatalError("init(nibName:bundle:) is unavailable, use init(servicesAssembly:) instead")
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        return nil
    }

    // MARK: - LifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        Self.logger.debug("viewDidLoad")
        setupUI()
        setupBindings()

        viewModel.loadItems()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        isNavigatingToPayment = false
        orderSummaryView.isUserInteractionEnabled = true
    }

    // MARK: - Setup UI
    private func setupUI() {
        view.backgroundColor = UIColor(resource: .nftWhite)

        tableView.dataSource = self
        tableView.delegate = self
        tableView.accessibilityIdentifier = "cart_table"
        refreshControl.addTarget(self, action: #selector(refreshPulled), for: .valueChanged)
        tableView.refreshControl = refreshControl

        view.addSubview(tableView)
        view.addSubview(orderSummaryView)
        view.addSubview(emptyStateLabel)

        tableView.translatesAutoresizingMaskIntoConstraints = false
        orderSummaryView.translatesAutoresizingMaskIntoConstraints = false
        emptyStateLabel.translatesAutoresizingMaskIntoConstraints = false

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

    // MARK: - Private methods
    private func setupBindings() {
        viewModel.onStateChange = { [weak self] state in
            guard let self else { return }
            DispatchQueue.main.async {
                if self.refreshControl.isRefreshing {
                    self.refreshControl.endRefreshing()
                }
                switch state {
                case .idle:
                    Self.logger.debug("State changed -> idle")
                case .loading:
                    Self.logger.debug("State changed -> loading")
                case .loaded(let items, let total):
                    Self.logger.info("State changed -> loaded. items=\(items.count), total=\(total, format: .fixed(precision: 2))")
                case .empty:
                    Self.logger.info("State changed -> empty")
                case .error(let message):
                    Self.logger.error("State changed -> error: \(message)")
                }
                self.render(state: state)
            }
        }

        orderSummaryView.onPayTapped = { [weak self] in
            guard let self else { return }
            guard !self.isNavigatingToPayment else { return }
            self.isNavigatingToPayment = true
            Self.logger.info("Pay tapped from cart. Navigating to PaymentViewController")
            self.orderSummaryView.isUserInteractionEnabled = false
            let vc = PaymentViewController()
            vc.hidesBottomBarWhenPushed = true
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }

    private func render(state: CartViewState) {
        Self.logger.debug("render called with state: \(String(describing: state))")
        switch state {
        case .idle:
            updateCartState()
        case .loading:
            UIBlockingProgressHUD.show()
            emptyStateLabel.isHidden = true
            orderSummaryView.isHidden = true
            navigationItem.rightBarButtonItem = nil
        case .loaded(let items, let total):
            UIBlockingProgressHUD.dismiss()
            emptyStateLabel.isHidden = true
            orderSummaryView.isHidden = false
            navigationItem.rightBarButtonItem = sortButton
            orderSummaryView.updateOrderSummary(count: items.count, price: total)
            tableView.reloadData()
        case .empty:
            UIBlockingProgressHUD.dismiss()
            emptyStateLabel.isHidden = false
            orderSummaryView.isHidden = true
            navigationItem.rightBarButtonItem = nil
            tableView.reloadData()
        case .error(let message):
            UIBlockingProgressHUD.dismiss()
            emptyStateLabel.isHidden = false
            orderSummaryView.isHidden = true
            navigationItem.rightBarButtonItem = nil
            tableView.reloadData()
            let alert = UIAlertController(title: Localization.Cart.emptyStateMessage.localized, message: message, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: Localization.Cart.close.localized, style: .default))
            present(alert, animated: true)
        }
    }

    private func updateCartState() {
        let isEmpty = viewModel.isEmpty()
        Self.logger.debug("updateCartState. isEmpty=\(isEmpty)")
        emptyStateLabel.isHidden = !isEmpty
        orderSummaryView.isHidden = isEmpty
        navigationItem.rightBarButtonItem = isEmpty ? nil : sortButton
    }

    private func showSortOptionsMenu() {
        Self.logger.debug("Showing sort options menu")
        let alert = UIAlertController(
            title: Localization.Cart.sort.localized,
            message: nil,
            preferredStyle: .actionSheet
        )

        for option in SortOption.allCases {
            let action = UIAlertAction(
                title: option.localizedWord,
                style: .default
            ) { [weak self] _ in
                Self.logger.info("Sort option selected: \(option.localizedWord)")
                self?.viewModel.sortOption = option
            }
            alert.addAction(action)
        }

        alert.addAction(UIAlertAction(title: Localization.Cart.close.localized, style: .cancel))

        present(alert, animated: true)
    }

    @objc private func refreshPulled() {
        Self.logger.info("Pull-to-refresh triggered")
        emptyStateLabel.isHidden = true
        viewModel.loadItems()
    }

    // MARK: - Actions
    @objc private func sortButtonTapped() {
        showSortOptionsMenu()
    }
}

extension CartViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        viewModel.itemsCount
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: CartItemViewCell = tableView.dequeueReusableCell()

        if let uiCartItem = viewModel.getUICartItem(at: indexPath.row) {
            cell.configure(data: uiCartItem)
            Self.logger.debug("Configured cell for row=\(indexPath.row), id=\(uiCartItem.id)")
            cell.onDeleteButtonTapped = { [weak self] in
                guard let self,
                      let indexPath = self.tableView.indexPath(for: cell) else { return }
                Self.logger.info("Delete button tapped for row=\(indexPath.row), id=\(uiCartItem.id)")
                let alertVC = DeleteConfirmationAlertViewController(image: uiCartItem.image)
                alertVC.onDeleteTapped = { [weak self] in
                    self?.viewModel.deleteItem(at: indexPath.row)
                }
                alertVC.onCancelTapped = {}

                alertVC.show(on: self)
            }
        }

        return cell
    }

    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        Self.logger.debug("Configuring trailing swipe actions for row=\(indexPath.row)")
        let deleteAction = UIContextualAction(style: .destructive, title: Localization.Cart.deleteButton.localized) { [weak self] _, _, completion in
            guard let self else { completion(false); return }
            Self.logger.info("Swipe-to-delete initiated for row=\(indexPath.row)")

            self.viewModel.deleteItem(at: indexPath.row)
            Self.logger.debug("Requested deletion for cart item at row=\(indexPath.row)")

            if self.viewModel.itemsCount >= indexPath.row {
                self.tableView.performBatchUpdates({
                    if self.tableView.numberOfRows(inSection: indexPath.section) > indexPath.row {
                        self.tableView.deleteRows(at: [indexPath], with: .automatic)
                    }
                }, completion: { _ in
                    Self.logger.debug("Row deleted via table updates for row=\(indexPath.row)")
                    completion(true)
                })
            } else {
                Self.logger.warning("Row index out of bounds during delete handling; completing without UI update")
                completion(true)
            }
        }
        deleteAction.backgroundColor = UIColor(resource: .nftRed)
        return UISwipeActionsConfiguration(actions: [deleteAction])
    }
}
