//
//  CartViewModelTests.swift
//  FakeNFT
//
//  Created by Дмитрий Чалов on 04.02.2026.
//
//  Описание:
//  Набор unit-тестов для CartViewModel, покрывающий ключевую бизнес-логику корзины:
//  - загрузка элементов из сервиса и формирование UI-моделей;
//  - удаление элемента и обновление итогов;
//  - сортировка по имени/рейтингу/цене;
//  - реакция на глобальное уведомление .cartDidChange (повторная загрузка).
//
//  Подход:
//  - Используем шпион SpyCartService с in-memory хранилищем, чтобы детерминированно управлять данными.
//  - SortOptionStore подменяем на MemorySortStore для изоляции от UserDefaults.
//  - Тесты проверяют как содержимое, так и побочные эффекты (количество обновлений, порядок элементов).
//

import Testing
@testable import FakeNFT
import Foundation

@Suite("CartViewModel unit tests")
struct CartViewModelTests {

    // MARK: - Test Doubles

    /// Шпион CartService с памятью для управления данными корзины.
    final class SpyCartService: CartServiceProtocol {
        var storage: [CartItem] = []

        func fetchCartItems(completion: @escaping (Result<[CartItem], Error>) -> Void) {
            completion(.success(storage))
        }

        func deleteCartItem(id: String, completion: @escaping () -> Void) {
            storage.removeAll { $0.id == id }
            completion()
        }

        func saveCartItems(_ items: [CartItem], completion: @escaping () -> Void) {
            storage = items
            completion()
        }

        func clearCart(completion: @escaping () -> Void) {
            storage.removeAll()
            completion()
        }
    }

    /// In-memory реализация SortOptionStore для изоляции от UserDefaults.
    final class MemorySortStore: SortOptionStore {
        var value: SortOption = .name
        func load() -> SortOption { value }
        func save(_ option: SortOption) { value = option }
    }

    // MARK: - Helpers

    /// Набор тестовых элементов корзины с разнообразными значениями для проверки сортировки/сумм.
    private func makeItems() -> [CartItem] {
        [
            CartItem(id: "1", name: "Alpha", images: ["mock"], rating: 3, price: 2.0),
            CartItem(id: "2", name: "Charlie", images: ["mock"], rating: 5, price: 1.0),
            CartItem(id: "3", name: "Bravo", images: ["mock"], rating: 1, price: 3.0)
        ]
    }

    // MARK: - Tests

    @Test("loadItems populates UI items and total price")
    /// Проверяет, что:
    /// - после загрузки элементы попадают в UI-модели,
    /// - вызывается onItemsUpdated,
    /// - корректно считается totalPrice.
    func testLoadItems() async throws {
        let service = SpyCartService()
        service.storage = makeItems()
        let store = MemorySortStore()

        let vm = CartViewModel(service: service, sortStore: store)

        var didUpdate = false
        vm.onItemsUpdated = { didUpdate = true }

        vm.loadItems()

        #expect(didUpdate, "onItemsUpdated должен вызываться при загрузке")
        #expect(vm.itemsCount == 3, "Ожидаем 3 элемента в корзине")
        #expect(abs(vm.totalPrice - 6.0) < 0.0001, "Сумма цен должна равняться 6.0")
    }

    @Test("deleteItem removes item and updates totals")
    /// Проверяет, что:
    /// - удаление по индексу приводит к уменьшению itemsCount,
    /// - корзина не становится пустой, если остаются элементы,
    /// - (косвенно) totalPrice и список пересчитываются.
    func testDeleteItem() async throws {
        let service = SpyCartService()
        service.storage = makeItems()
        let store = MemorySortStore()
        let vm = CartViewModel(service: service, sortStore: store)

        vm.loadItems()
        #expect(vm.itemsCount == 3)

        vm.deleteItem(at: 1)
        #expect(vm.itemsCount == 2, "После удаления должен остаться 2 элемента")
        #expect(vm.isEmpty() == false, "Корзина не должна быть пустой")
    }

    @Test("sortItems by name, rating, price")
    /// Проверяет корректность сортировки:
    /// - по имени (возрастание),
    /// - по рейтингу (убывание),
    /// - по цене (возрастание, с учетом того, что сортируется cartItems).
    func testSortItems() async throws {
        let service = SpyCartService()
        service.storage = makeItems()
        let store = MemorySortStore()
        let vm = CartViewModel(service: service, sortStore: store)

        vm.loadItems()

        vm.sortOption = .name
        #expect(vm.items.map { $0.title } == ["Alpha", "Bravo", "Charlie"], "Сортировка по имени должна быть по возрастанию")

        vm.sortOption = .rating
        #expect(vm.items.map { $0.rating } == [5, 3, 1], "Сортировка по рейтингу должна быть по убыванию")

        vm.sortOption = .price
        // при сортировке по цене сортируется cartItems, а items пересобираются при изменениях
        vm.sortItems()
        #expect(vm.items.first?.title == "Charlie", "Самый дешевый товар должен оказаться первым")
    }

    @Test("cartDidChange triggers reload")
    /// Проверяет реакцию на глобальное уведомление:
    /// - после .cartDidChange повторно загружаются элементы,
    /// - onItemsUpdated вызывается как минимум еще раз,
    /// - данные в items соответствуют актуальному хранилищу.
    func testCartDidChange() async throws {
        let service = SpyCartService()
        let store = MemorySortStore()
        let vm = CartViewModel(service: service, sortStore: store)

        var updates = 0
        vm.onItemsUpdated = { updates += 1 }

        vm.loadItems()
        #expect(updates >= 1, "После первой загрузки должен быть хотя бы один апдейт")
        
        service.storage = makeItems()
        NotificationCenter.default.post(name: .cartDidChange, object: nil)

        #expect(updates >= 2, "После нотификации должен быть еще один апдейт")
        #expect(vm.itemsCount == 3, "После перезагрузки ожидаем 3 элемента")
    }
}

