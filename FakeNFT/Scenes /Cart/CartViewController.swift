//
//  CartViewController.swift
//  FakeNFT
//
//  Created by Дмитрий Чалов on 24.01.2026.
//

import UIKit
import OSLog

final class SearchTitleContainerView: UIView {
    private let fixedWidth: CGFloat

    init(width: CGFloat) {
        self.fixedWidth = width
        super.init(frame: .zero)
        translatesAutoresizingMaskIntoConstraints = false
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        nil
    }

    override var intrinsicContentSize: CGSize {
        CGSize(width: fixedWidth, height: 36)
    }

    override func sizeThatFits(_ size: CGSize) -> CGSize {
        intrinsicContentSize
    }
}

final class CartViewController: UIViewController {

    static let logger = Logger(subsystem: "com.fakenft.app", category: "CartViewController")

    // MARK: - Dependencies
    let viewModel: CartViewModelProtocol
    let servicesAssembly: ServicesAssembly

    // MARK: - State
    var isNavigatingToPayment = false
    let connectivity = ConnectivityService()

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

    lazy var searchTextField: UITextField = {
        let textField = UITextField(frame: .zero)
        textField.placeholder = "Search"
        textField.borderStyle = .none
        textField.backgroundColor = .clear
        textField.textColor = UIColor(resource: .nftBlack)
        textField.autocapitalizationType = .none
        textField.clearButtonMode = .whileEditing
        textField.returnKeyType = .search
        textField.delegate = self
        textField.setContentHuggingPriority(.defaultLow, for: .horizontal)
        textField.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)

        let leftIcon = UIImageView(image: UIImage(systemName: "magnifyingglass"))
        leftIcon.tintColor = UIColor(resource: .nftBlack).withAlphaComponent(0.6)
        leftIcon.contentMode = .scaleAspectFit
        leftIcon.frame = CGRect(x: 0, y: 0, width: 16, height: 16)
        let leftContainer = UIView(frame: CGRect(x: 0, y: 0, width: 28, height: 16))
        leftContainer.addSubview(leftIcon)
        leftIcon.center = CGPoint(x: leftContainer.bounds.midX, y: leftContainer.bounds.midY)
        textField.leftView = leftContainer
        textField.leftViewMode = .always

        textField.addTarget(self, action: #selector(searchTextChanged(_:)), for: .editingChanged)
        return textField
    }()

    lazy var searchTitleContainer: UIView = {
        let targetWidth = min(max(UIScreen.main.bounds.width - 130, 260), 340)
        let container = SearchTitleContainerView(width: targetWidth)
        container.backgroundColor = .clear
        container.layer.cornerRadius = 18
        container.layer.cornerCurve = .continuous
        container.layer.masksToBounds = true

        let blur = UIBlurEffect(style: .systemUltraThinMaterialLight)
        let blurView = UIVisualEffectView(effect: blur)
        blurView.translatesAutoresizingMaskIntoConstraints = false
        blurView.isUserInteractionEnabled = false
        container.addSubview(blurView)

        let tintLayer = UIView()
        tintLayer.translatesAutoresizingMaskIntoConstraints = false
        tintLayer.backgroundColor = UIColor.white.withAlphaComponent(0.15)
        tintLayer.isUserInteractionEnabled = false
        container.addSubview(tintLayer)

        searchTextField.translatesAutoresizingMaskIntoConstraints = false
        container.addSubview(searchTextField)
        NSLayoutConstraint.activate([
            container.widthAnchor.constraint(equalToConstant: targetWidth),
            container.heightAnchor.constraint(equalToConstant: 36),

            blurView.topAnchor.constraint(equalTo: container.topAnchor),
            blurView.leadingAnchor.constraint(equalTo: container.leadingAnchor),
            blurView.trailingAnchor.constraint(equalTo: container.trailingAnchor),
            blurView.bottomAnchor.constraint(equalTo: container.bottomAnchor),

            tintLayer.topAnchor.constraint(equalTo: container.topAnchor),
            tintLayer.leadingAnchor.constraint(equalTo: container.leadingAnchor),
            tintLayer.trailingAnchor.constraint(equalTo: container.trailingAnchor),
            tintLayer.bottomAnchor.constraint(equalTo: container.bottomAnchor),

            searchTextField.topAnchor.constraint(equalTo: container.topAnchor),
            searchTextField.bottomAnchor.constraint(equalTo: container.bottomAnchor),
            searchTextField.leadingAnchor.constraint(equalTo: container.leadingAnchor),
            searchTextField.trailingAnchor.constraint(equalTo: container.trailingAnchor)
        ])
        return container
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
        connectivity.start()

        setupUI()
        setupBindings()
        loadItemsOrShowOfflineAlert()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        isNavigatingToPayment = false
        orderSummaryView.isUserInteractionEnabled = true
    }

    deinit {
        connectivity.stop()
    }
}

// MARK: - Setup
private extension CartViewController {
    func setupUI() {
        view.backgroundColor = UIColor(resource: .nftWhite)
        configureTableView()
        configureSearch()

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
        tableView.keyboardDismissMode = .interactive
        refreshControl.addTarget(self, action: #selector(refreshPulled), for: .valueChanged)
        tableView.refreshControl = refreshControl
    }

    func configureSearch() {
        let rootTapGesture = UITapGestureRecognizer(target: self, action: #selector(handleBackgroundTap))
        rootTapGesture.cancelsTouchesInView = false
        rootTapGesture.delegate = self
        view.addGestureRecognizer(rootTapGesture)

        let tableTapGesture = UITapGestureRecognizer(target: self, action: #selector(handleBackgroundTap))
        tableTapGesture.cancelsTouchesInView = false
        tableTapGesture.delegate = self
        tableView.addGestureRecognizer(tableTapGesture)

        setSearchVisible(false)
    }
}
