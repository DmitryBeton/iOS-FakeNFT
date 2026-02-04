//
//  CartViewModelTests.swift
//  FakeNFT
//
//  Created by Дмитрий Чалов on 04.02.2026.
//


import Testing
@testable import FakeNFT
import Foundation

@Suite("CartViewModel unit tests")
struct CartViewModelTests {

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

    final class MemorySortStore: SortOptionStore {
        var value: SortOption = .name
        func load() -> SortOption { value }
        func save(_ option: SortOption) { value = option }
    }

    private func makeItems() -> [CartItem] {
        [
            CartItem(id: "1", name: "Alpha", images: ["mock"], rating: 3, price: 2.0),
            CartItem(id: "2", name: "Charlie", images: ["mock"], rating: 5, price: 1.0),
            CartItem(id: "3", name: "Bravo", images: ["mock"], rating: 1, price: 3.0)
        ]
    }

    @Test("loadItems populates UI items and total price")
    func testLoadItems() async throws {
        let service = SpyCartService()
        service.storage = makeItems()
        let store = MemorySortStore()

        let vm = CartViewModel(service: service, sortStore: store)

        var didUpdate = false
        vm.onItemsUpdated = { didUpdate = true }

        vm.loadItems()

        #expect(didUpdate)
        #expect(vm.itemsCount == 3)
        #expect(abs(vm.totalPrice - 6.0) < 0.0001)
    }

    @Test("deleteItem removes item and updates totals")
    func testDeleteItem() async throws {
        let service = SpyCartService()
        service.storage = makeItems()
        let store = MemorySortStore()
        let vm = CartViewModel(service: service, sortStore: store)

        vm.loadItems()
        #expect(vm.itemsCount == 3)

        vm.deleteItem(at: 1)
        #expect(vm.itemsCount == 2)
        #expect(vm.isEmpty() == false)
    }

    @Test("sortItems by name, rating, price")
    func testSortItems() async throws {
        let service = SpyCartService()
        service.storage = makeItems()
        let store = MemorySortStore()
        let vm = CartViewModel(service: service, sortStore: store)

        vm.loadItems()

        vm.sortOption = .name
        #expect(vm.items.map { $0.title } == ["Alpha", "Bravo", "Charlie"])

        vm.sortOption = .rating
        #expect(vm.items.map { $0.rating } == [5, 3, 1])

        vm.sortOption = .price
        // при сортировке по цене сортируется cartItems, а items пересобираются при изменениях
        // поэтому проверим, что самый дешевый товар теперь первый в UI после ручного вызова sortItems
        vm.sortItems()
        #expect(vm.items.first?.title == "Charlie")
    }

    @Test("cartDidChange triggers reload")
    func testCartDidChange() async throws {
        let service = SpyCartService()
        let store = MemorySortStore()
        let vm = CartViewModel(service: service, sortStore: store)

        var updates = 0
        vm.onItemsUpdated = { updates += 1 }

        vm.loadItems()
        #expect(updates >= 1)

        service.storage = makeItems()
        NotificationCenter.default.post(name: .cartDidChange, object: nil)

        #expect(updates >= 2)
        #expect(vm.itemsCount == 3)
    }
}

