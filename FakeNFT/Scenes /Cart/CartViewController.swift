//
//  CartViewController.swift
//  FakeNFT
//
//  Created by Дмитрий Чалов on 24.01.2026.
//

import UIKit

final class CartViewController: UIViewController {
    
    private let mockData = [
        UICartItem(id: UUID(), image: UIImage(resource: .mock), title: "April", rating: 1, price: "1,78 ETH"),
        UICartItem(id: UUID(), image: UIImage(resource: .mock2), title: "Greena", rating: 3, price: "1,78 ETH"),
        UICartItem(id: UUID(), image: UIImage(resource: .mock3), title: "Spring", rating: 5, price: "1,78 ETH")
    ]
    
    // MARK: - UI Elements
    let tableView: UITableView = {
        let tableView = UITableView()
        tableView.allowsSelection = false
        tableView.register(CartItemViewCell.self)
        tableView.estimatedRowHeight = 140
        tableView.separatorStyle = .none
        tableView.backgroundColor = .clear
        return tableView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = UIColor(resource: .nftWhite)
        tableView.dataSource = self

        view.addSubview(tableView)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
        ])

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
