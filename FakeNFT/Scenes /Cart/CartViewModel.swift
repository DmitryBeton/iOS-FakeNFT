//
//  CartViewModel.swift
//  FakeNFT
//
//  Created by Дмитрий Чалов on 25.01.2026.
//

import UIKit
import OSLog

/// Состояния экрана корзины (FSM)
enum CartViewState {
    case idle
    case loading
    case loadingPlaceholders(items: [UICartItem])
    case loaded(items: [UICartItem], total: Double)
    case empty
    case error(message: String)
}

/// Протокол описывает интерфейс для ViewModel корзины, отвечающей за представление и управление товарами в корзине.
/// Поддерживает обновление элементов, сортировку и удаление товаров.
protocol CartViewModelProtocol: AnyObject {
    /// Текущий параметр сортировки.
    var sortOption: SortOption { get set }

    /// Текущее состояние экрана корзины.
    var state: CartViewState { get }

    /// Замыкание вызывается при изменении состояния экрана.
    var onStateChange: ((CartViewState) -> Void)? { get set }

    /// Количество элементов в корзине.
    var itemsCount: Int { get }

    /// Общая стоимость товаров в корзине.
    var totalPrice: Double { get }

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
    private static let logger = Logger(subsystem: "com.fakenft.app", category: "CartViewModel")

    // MARK: - Dependencies
    private let service: CartServiceProtocol
    private let sortStore: SortOptionStore
    private var requestedItemIDs: [String] = []

    // MARK: - Backing storage
    private var cartItems: [CartItem] = [] {
        didSet {
            Self.logger.debug("cartItems didSet. newCount=\(self.cartItems.count)")
            totalPrice = cartItems.reduce(0) { $0 + $1.price }
        }
    }

    // MARK: - Init
    init(service: CartServiceProtocol,
         sortStore: SortOptionStore = UserDefaultsSortOptionStore()) {
        self.service = service
        self.sortStore = sortStore

        self.sortOption = sortStore.load()
        self.state = .idle
        Self.logger.debug("CartViewModel initialized with sortOption=\(self.sortOption.localizedWord)")

//        NotificationCenter.default.addObserver(self,
//                                               selector: #selector(handleCartDidChange(_:)),
//                                               name: .cartDidChange,
//                                               object: nil)
    }
//
//    deinit {
//        Self.logger.debug("CartViewModel deinit")
//        NotificationCenter.default.removeObserver(self, name: .cartDidChange, object: nil)
//    }

    // MARK: - Properties
    private(set) var state: CartViewState = .idle {
        didSet {
            onStateChange?(state)
        }
    }

    var items: [UICartItem] = []

    var itemsCount: Int { items.count }

    var totalPrice: Double = 0

    var sortOption: SortOption {
        didSet {
            sortStore.save(sortOption)
            sortItems()
            onSortChanged?()
        }
    }

    var onStateChange: ((CartViewState) -> Void)?
    var onSortChanged: (() -> Void)?

    // MARK: - Public Methods
    func loadItems() {
        Self.logger.info("Loading cart items started")
        state = .loading
        self.service.fetchCartItems(onPlaceholders: { [weak self] ids in
            guard let self else { return }
            Self.logger.info("Received placeholders IDs. count=\(ids.count)")
            self.applyPlaceholderItems(for: ids)
        }, onPartialUpdate: { [weak self] partialItems in
            guard let self else { return }
            Self.logger.info("Received partial cart items. count=\(partialItems.count)")
            self.applyPartialItems(partialItems)
        }, completion: { [weak self] result in
            guard let self else { return }
            switch result {
            case .success(let items):
                Self.logger.info("Cart items loaded successfully. count=\(items.count)")
                self.requestedItemIDs = []
                // Always finalize into .loaded/.empty after placeholders/partials.
                // Even if payload is unchanged, UI must leave loadingPlaceholders state.
                self.applyLoadedItems(items)
            case .failure:
                Self.logger.error("Failed to load cart items")
                if self.cartItems.isEmpty {
                    self.state = .error(message: "Не удалось загрузить корзину")
                } else {
                    // Keep last known content visible if refresh failed.
                    self.sortItems()
                }
            }
        })
    }

    func deleteItem(at index: Int) {
        Self.logger.info("Request to delete item at index=\(index)")
        guard index < items.count else { return }
        Self.logger.debug("Deleting item id=\(self.items[index].id)")
        let id = items[index].id
//        self.service.deleteCartItem(id: id) { [weak self] in
//            guard let self else { return }
//            Self.logger.info("Cart item deleted successfully. id=\(id)")
//            self.cartItems.removeAll { $0.id == id }
//        }
    }

    func sortItems() {
        Self.logger.debug("Sorting items by option=\(self.sortOption.localizedWord)")
        switch sortOption {
        case .name:
            cartItems.sort { $0.name.localizedCaseInsensitiveCompare($1.name) == .orderedAscending }
        case .rating:
            cartItems.sort { $0.rating > $1.rating }
        case .price:
            cartItems.sort { $0.price < $1.price }
        }
        items = cartItems.map { self.mapToUI($0) }
        Self.logger.debug("Sorted items ready. count=\(self.items.count)")
        emitLoadedOrEmptyState()
    }

    func getUICartItem(at index: Int) -> UICartItem? {
        Self.logger.debug("getUICartItem called for index=\(index)")
        guard index < items.count else { return nil }
        return items[index]
    }

    func isEmpty() -> Bool {
        Self.logger.debug("isEmpty queried -> \(self.items.isEmpty)")
        return items.isEmpty
    }

    // MARK: - Mapping
    private func mapToUI(_ item: CartItem) -> UICartItem {
        let imageURL = item.images.first.flatMap(URL.init(string:))
        let formattedPrice = String(format: "%.2f ETH", item.price)
        return UICartItem(
            id: item.id,
            imageURL: imageURL,
            title: item.name,
            rating: item.rating,
            price: formattedPrice,
            isPlaceholder: false
        )
    }

    // MARK: - Notifications
    @objc private func handleCartDidChange(_ notification: Notification) {
        Self.logger.info("Notification received: cartDidChange. Reloading items")
        loadItems()
    }

    private func applyLoadedItems(_ newItems: [CartItem]) {
        cartItems = newItems
        sortItems()
    }

    private func emitLoadedOrEmptyState() {
        if items.isEmpty {
            state = .empty
        } else {
            state = .loaded(items: items, total: totalPrice)
        }
    }

    private func applyPlaceholderItems(for ids: [String]) {
        requestedItemIDs = ids
        items = ids.map(makePlaceholderItem)
        state = .loadingPlaceholders(items: items)
    }

    private func applyPartialItems(_ partialItems: [CartItem]) {
        guard !requestedItemIDs.isEmpty else {
            applyLoadedItems(partialItems)
            return
        }

        let partialByID = Dictionary(uniqueKeysWithValues: partialItems.map { ($0.id, $0) })
        items = requestedItemIDs.map { id in
            if let realItem = partialByID[id] {
                return mapToUI(realItem)
            }
            return makePlaceholderItem(id: id)
        }
        state = .loadingPlaceholders(items: items)
    }

    private func makePlaceholderItem(id: String) -> UICartItem {
        UICartItem(
            id: id,
            imageURL: nil,
            title: "",
            rating: 0,
            price: "",
            isPlaceholder: true
        )
    }
}
