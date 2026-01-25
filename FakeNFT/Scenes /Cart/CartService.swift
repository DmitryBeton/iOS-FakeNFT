//
//  CartService.swift
//  FakeNFT
//
//  Created by Дмитрий Чалов on 25.01.2026.
//

import Foundation

protocol CartServiceProtocol {
    func fetchCartItems(completion: @escaping (Result<[CartItem], Error>) -> Void)
    func deleteCartItem(id: String, completion: @escaping () -> Void)
    func saveCartItems(_ items: [CartItem], completion: @escaping () -> Void)
}

final class CartService: CartServiceProtocol {
    
    // MARK: - Properties
    private let repository: CartRepositoryProtocol
    private let networkClient: NetworkClient
    
    // MARK: - Initialization
    init(repository: CartRepositoryProtocol = CartRepository(),
         networkClient: NetworkClient = DefaultNetworkClient()) {
        self.repository = repository
        self.networkClient = networkClient
    }
    
    // MARK: - Public Methods
    func fetchCartItems(completion: @escaping (Result<[CartItem], Error>) -> Void) {
        // TODO: - Добавить загрузку данных из сети по id(они в userDefaults)
        let items = repository.getCartItems()
        completion(.success(items))
    }
    
    func deleteCartItem(id: String, completion: @escaping () -> Void) {
        repository.deleteCartItem(with: id)
        completion()
    }
    
    func saveCartItems(_ items: [CartItem], completion: @escaping () -> Void) {
        repository.saveCartItems(items)
        completion()
    }
}

