//
//  CartViewModel.swift
//  FakeNFT
//
//  Created by Дмитрий Чалов on 25.01.2026.
//

import UIKit

protocol CartViewModelProtocol: AnyObject {
    var items: [UICartItem] { get }  // TODO: во 2 модуле заменю структуру на СartItem
    var itemsCount: Int { get }
    var totalPrice: Double { get }
    var sortOption: SortOption { get set }
    var onItemsUpdated: (() -> Void)? { get set }
    var onSortChanged: (() -> Void)? { get set }
    
    func loadItems()
    func deleteItem(at index: Int)
    func sortItems(by option: SortOption)
}

final class CartViewModel: CartViewModelProtocol {
    // MARK: - Properties
    var items: [UICartItem] = [] {
        didSet {
            onItemsUpdated?()
        }
    }
    
    lazy var itemsCount: Int = items.count
    
    var totalPrice: Double = 5.34
    
    var sortOption: SortOption = .name {
        didSet {
            sortItems(by: sortOption)
            onSortChanged?()
        }
    }

    var onItemsUpdated: (() -> Void)?
    
    var onSortChanged: (() -> Void)?

    // MARK: - Public Methods
    func loadItems() {
        items = [
            UICartItem(id: UUID(), image: UIImage(resource: .mock), title: "April", rating: 1, price: "1,78 ETH"),
            UICartItem(id: UUID(), image: UIImage(resource: .mock2), title: "Greena", rating: 3, price: "1,78 ETH"),
            UICartItem(id: UUID(), image: UIImage(resource: .mock3), title: "Spring", rating: 5, price: "1,78 ETH")
        ]
    }
    
    func deleteItem(at index: Int) {
        guard index < items.count else { return }
        
        let itemId = items[index].id
        items.remove(at: index)
    }
    
    func sortItems(by option: SortOption) {
        sortOption = option
        
        switch option {
        case .name:
            items.sort { $0.title < $1.title }
        case .rating:
            items.sort { $0.rating > $1.rating }
        case .price:
            items.sort { $0.price < $1.price }
        }

    }
    
}
