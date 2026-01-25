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
    func sortItems()
    
    func getUICartItem(at index: Int) -> UICartItem?
    func isEmpty() -> Bool
}

final class CartViewModel: CartViewModelProtocol {
    // MARK: - Properties
    var items: [UICartItem] = [] {
        didSet {
            onItemsUpdated?()
        }
    }
    
    var itemsCount: Int { items.count }
    
    var totalPrice: Double = 5.34 // TODO: - Добавлю изменение во 2 модуле когда будет структура CartItem
    
    var sortOption: SortOption = .name {
        didSet {
            sortItems()
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
        items.remove(at: index)
    }
    
    func sortItems() {
        switch sortOption {
        case .name:
            items.sort { $0.title < $1.title }
        case .rating:
            items.sort { $0.rating > $1.rating }
        case .price:
            items.sort { $0.price < $1.price }
        }

    }
    
    // в будущем будет конвертировать cartItem в UICartItem
    func getUICartItem(at index: Int) -> UICartItem? {
        guard index < items.count else { return nil }
        return items[index]
    }
    
    func isEmpty() -> Bool {
        items.isEmpty
    }

}
