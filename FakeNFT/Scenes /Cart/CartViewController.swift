//
//  CartViewController.swift
//  FakeNFT
//
//  Created by Дмитрий Чалов on 24.01.2026.
//

import UIKit

final class CartViewController: UIViewController {
    
    // MARK: - Properties
    private let mockData = [
        UICartItem(id: UUID(), image: UIImage(resource: .mock), title: "April", rating: 1, price: "1,78 ETH"),
        UICartItem(id: UUID(), image: UIImage(resource: .mock2), title: "Greena", rating: 3, price: "1,78 ETH"),
        UICartItem(id: UUID(), image: UIImage(resource: .mock3), title: "Spring", rating: 5, price: "1,78 ETH")
    ]
    private var sortOption: SortOption = .name
    
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
    
    // MARK: - LifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        orderSummaryView.updateOrderSummary(count: 3, price: 5.34)
        setupNavigationBar()
        
        view.backgroundColor = UIColor(resource: .nftWhite)
        tableView.dataSource = self

        view.addSubview(tableView)
        view.addSubview(orderSummaryView)
        
        tableView.translatesAutoresizingMaskIntoConstraints = false
        orderSummaryView.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: orderSummaryView.topAnchor),
            
            orderSummaryView.heightAnchor.constraint(equalToConstant: 76),
            orderSummaryView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            orderSummaryView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            orderSummaryView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor)
        ])

    }
    // MARK: - Setup UI
    private func setupNavigationBar() {
        let sortButton = UIBarButtonItem(
            image: UIImage(resource: .sortIcon),
            style: .plain,
            target: self,
            action: #selector(sortButtonTapped)
        )
        sortButton.tintColor = UIColor(resource: .nftBlack)
        navigationItem.rightBarButtonItem = sortButton
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
                self?.sortOption = option
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
        3
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell: CartItemViewCell = tableView.dequeueReusableCell()

        cell.configure(data: mockData[indexPath.row])
        return cell

    }
}
