//
//  CartRepository.swift
//  FakeNFT
//
//  Created by Дмитрий Чалов on 25.01.2026.
//

import Foundation

protocol CartRepositoryProtocol {
    func getCartItems() -> [CartItem]
    func saveCartItems(_ items: [CartItem])
    func deleteCartItem(with id: String)
    func clearCart()
}

final class CartRepository: CartRepositoryProtocol {
    
    // MARK: - Properties
    private let userDefaultsKey = "cart_items"
    private var mockCartItems: [CartItem] = [
        CartItem(
            id: "b3907b86-37c4-4e15-95bc-7f8147a9a660",
            name: "mel novum",
            images: ["https://code.s3.yandex.net/Mobile/iOS/NFT/White/Lumpy/1.png",
                     "https://code.s3.yandex.net/Mobile/iOS/NFT/White/Lumpy/2.png",
                     "https://code.s3.yandex.net/Mobile/iOS/NFT/White/Lumpy/3.png"],
            rating: 4,
            price: 49.77,
        ),
        CartItem(
            id: "739e293c-1067-43e5-8f1d-4377e744ddde",
            name: "commodo porttitor",
            images: ["https://code.s3.yandex.net/Mobile/iOS/NFT/Beige/April/1.png",
                     "https://code.s3.yandex.net/Mobile/iOS/NFT/Beige/April/2.png",
                     "https://code.s3.yandex.net/Mobile/iOS/NFT/Beige/April/3.png"],
            rating: 3,
            price: 36.54,
        ),
        CartItem(
            id: "1e649115-1d4f-4026-ad56-9551a16763ee",
            name: "delenit verterem elaboraret",
            images: ["https://code.s3.yandex.net/Mobile/iOS/NFT/Brown/Emma/1.png",
                     "https://code.s3.yandex.net/Mobile/iOS/NFT/Brown/Emma/2.png",
                     "https://code.s3.yandex.net/Mobile/iOS/NFT/Brown/Emma/3.png"],
            rating: 5,
            price: 28.82,
        )
    ]
    
    // MARK: - Public Methods
    func getCartItems() -> [CartItem] {
        mockCartItems
    }
    
    func saveCartItems(_ items: [CartItem]) {
        mockCartItems = items
    }
    
    func deleteCartItem(with id: String) {
        var items = getCartItems()
        items.removeAll { $0.id == id }
        saveCartItems(items)
    }
    
    func clearCart() {
        mockCartItems = []
    }
}
