//
//  CartViewController.swift
//  FakeNFT
//
//  Created by Дмитрий Чалов on 24.01.2026.
//

import UIKit

final class CartViewController: UIViewController {
    
    // MARK: - Properties
    private let viewModel: CartViewModelProtocol
    
    // MARK: - UI Elements
    private let tableView: UITableView = {
        let tableView = UITableView()
        tableView.allowsSelection = false
        tableView.register(CartItemViewCell.self)
        tableView.estimatedRowHeight = 140
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
        return sortButton
    }()
    
    // MARK: - Initialization
    init(viewModel: CartViewModelProtocol = CartViewModel()) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        nil
    }
    
    // MARK: - LifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupBindings()
        
        viewModel.loadItems()
    }
    
    // MARK: - Setup UI
    private func setupUI() {
        view.backgroundColor = UIColor(resource: .nftWhite)
        
        tableView.dataSource = self
        
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
            emptyStateLabel.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -16),
            
            
        ])
        
    }
    
    // MARK: - Private methods
    private func setupBindings() {
        viewModel.onItemsUpdated = { [weak self] in
            guard let self = self else { return }
            
            DispatchQueue.main.async {
                self.tableView.reloadData()
                self.updateCartState()
                self.orderSummaryView.updateOrderSummary(
                    count: self.viewModel.itemsCount,
                    price: self.viewModel.totalPrice
                )
            }
        }
        
        viewModel.onSortChanged = { [weak self] in
            guard let self = self else { return }
            
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        }
    }
    
    private func updateCartState() {
        let isEmpty = viewModel.isEmpty()
        emptyStateLabel.isHidden = !isEmpty
        orderSummaryView.isHidden = isEmpty
        navigationItem.rightBarButtonItem = isEmpty ? nil : sortButton
    }
    
    private func showSortOptionsMenu() {
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
                self?.viewModel.sortOption = option
            }
            alert.addAction(action)
        }
        
        alert.addAction(UIAlertAction(title: Localization.Cart.close.localized, style: .cancel))
        
        present(alert, animated: true)
    }
    
    // MARK: - Actions
    @objc private func sortButtonTapped() {
        showSortOptionsMenu()
    }
}

extension CartViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        viewModel.itemsCount
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: CartItemViewCell = tableView.dequeueReusableCell()
        
        if let uiCartItem = viewModel.getUICartItem(at: indexPath.row) {
            cell.configure(data: uiCartItem)
            cell.onDeleteButtonTapped = { [weak self] in
                guard let self = self,
                      let indexPath = self.tableView.indexPath(for: cell) else { return }
                
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
}
