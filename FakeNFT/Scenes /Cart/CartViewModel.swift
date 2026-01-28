//
//  CartViewModel.swift
//  FakeNFT
//
//  Created by Дмитрий Чалов on 25.01.2026.
//

import UIKit

/// Протокол описывает интерфейс для ViewModel корзины, отвечающей за представление и управление товарами в корзине.
/// Поддерживает обновление элементов, сортировку и удаление товаров.
protocol CartViewModelProtocol: AnyObject {
    /// Массив отображаемых элементов корзины для UI.
    var items: [UICartItem] { get }
    
    /// Количество элементов в корзине.
    var itemsCount: Int { get }
    
    /// Общая стоимость товаров в корзине.
    var totalPrice: Double { get }
    
    /// Текущий параметр сортировки.
    var sortOption: SortOption { get set }
    
    /// Замыкание вызывается при обновлении списка элементов.
    var onItemsUpdated: (() -> Void)? { get set }
    
    /// Замыкание вызывается при изменении способа сортировки.
    var onSortChanged: (() -> Void)? { get set }
    
    /// Загружает все элементы корзины.
    func loadItems()
    
    /// Удаляет элемент корзины по индексу.
    /// - Parameter index: Индекс элемента для удаления.
    func deleteItem(at index: Int)
    
    /// Сортирует элементы корзины согласно выбранному способу сортировки.
    func sortItems()
    
    /// Возвращает элемент корзины для UI по индексу.
    /// - Parameter index: Индекс элемента.
    func getUICartItem(at index: Int) -> UICartItem?
    
    /// Возвращает признак, пуста ли корзина.
    func isEmpty() -> Bool
}

final class CartViewModel: CartViewModelProtocol {
    // MARK: - Dependencies
    private let service: CartServiceProtocol
    private let sortStore: SortOptionStore
    
    // MARK: - Backing storage
    private var cartItems: [CartItem] = [] {
        didSet {
            items = cartItems.map { self.mapToUI($0) }
            totalPrice = cartItems.reduce(0) { $0 + $1.price }
        }
    }
    
    // MARK: - Init
    init(service: CartServiceProtocol = CartService(),
         sortStore: SortOptionStore = UserDefaultsSortOptionStore()) {
        self.service = service
        self.sortStore = sortStore
        
        self.sortOption = sortStore.load()
    }
    
    // MARK: - Properties
    var items: [UICartItem] = [] {
        didSet {
            onItemsUpdated?()
        }
    }
    
    var itemsCount: Int { items.count }
    
    var totalPrice: Double = 0
    
    var sortOption: SortOption {
        didSet {
            sortStore.save(sortOption)
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
                // TODO: - добавить обработку ошибок
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
            cartItems.sort { $0.price < $1.price }
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
        let formattedPrice = String(format: "%.2f ETH", item.price)
        return UICartItem(
            id: item.id,
            image: placeholder,
            title: item.name,
            rating: item.rating,
            price: formattedPrice
        )
    }
}

