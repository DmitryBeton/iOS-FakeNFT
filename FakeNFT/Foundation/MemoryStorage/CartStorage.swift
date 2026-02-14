import Foundation

protocol CartStorage {
    func isInCart(nftId: String) -> Bool
    func addToCart(nftId: String)
    func removeFromCart(nftId: String)
    func toggleCart(nftId: String) -> Bool
    func getAllCartItems() -> [String]
}

final class CartStorageImpl: CartStorage {

    static let shared = CartStorageImpl()

    private let userDefaults = UserDefaults.standard
    private let cartKey = "CartNFTs"

    private init() {}

    func isInCart(nftId: String) -> Bool {
        let cartItems = getAllCartItems()
        return cartItems.contains(nftId)
    }

    func addToCart(nftId: String) {
        var cartItems = getAllCartItems()
        guard !cartItems.contains(nftId) else { return }
        cartItems.append(nftId)
        saveCartItems(cartItems)
    }

    func removeFromCart(nftId: String) {
        var cartItems = getAllCartItems()
        cartItems.removeAll { $0 == nftId }
        saveCartItems(cartItems)
    }

    func toggleCart(nftId: String) -> Bool {
        if isInCart(nftId: nftId) {
            removeFromCart(nftId: nftId)
            return false
        } else {
            addToCart(nftId: nftId)
            return true
        }
    }

    func getAllCartItems() -> [String] {
        return userDefaults.stringArray(forKey: cartKey) ?? []
    }

    private func saveCartItems(_ cartItems: [String]) {
        userDefaults.set(cartItems, forKey: cartKey)
    }
}
