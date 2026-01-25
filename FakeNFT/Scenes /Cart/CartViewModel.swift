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
    // MARK: - Dependencies
    private let service: CartServiceProtocol
    
    // MARK: - Backing storage
    private var cartItems: [CartItem] = [] {
        didSet {
            items = cartItems.map { self.mapToUI($0) }
            totalPrice = cartItems.reduce(0) { $0 + $1.price }
            sortItems()
        }
    }
    
    // MARK: - Init
    init(service: CartServiceProtocol = CartService()) {
        self.service = service
    }
    
    // MARK: - Properties
    var items: [UICartItem] = [] {
        didSet {
            onItemsUpdated?()
        }
    }
    
    var itemsCount: Int { items.count }
    
    var totalPrice: Double = 0
    
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
        service.fetchCartItems { [weak self] result in
            guard let self else { return }
            switch result {
            case .success(let items):
                self.cartItems = items
            case .failure:
                // В простом варианте очищаем при ошибке
                self.cartItems = []
            }
        }
    }
    
    func deleteItem(at index: Int) {
        guard index < items.count else { return }
        let id = items[index].id
        service.deleteCartItem(id: id) { [weak self] in
            guard let self else { return }
            self.cartItems.removeAll { $0.id == id }
        }
    }
    
    func sortItems() {
        switch sortOption {
        case .name:
            items.sort { $0.title < $1.title }
        case .rating:
            items.sort { $0.rating > $1.rating }
        case .price:
            items.sort { $0.price > $1.price }
        }
    }
    
    func getUICartItem(at index: Int) -> UICartItem? {
        guard index < items.count else { return nil }
        return items[index]
    }
    
    func isEmpty() -> Bool {
        items.isEmpty
    }
    
    // MARK: - Mapping
    private func mapToUI(_ item: CartItem) -> UICartItem {
        // Плейсхолдер т.к. загрузки по URL пока нет
        let placeholder = UIImage(resource: .mock)
        // TODO: - в будущем заменить ETH на выбранную в currencyService валюту
        let formattedPrice = String(format: "%,2f ETH", item.price)
        return UICartItem(
            id: item.id,
            image: placeholder,
            title: item.name,
            rating: item.rating,
            price: formattedPrice
        )
    }
}

