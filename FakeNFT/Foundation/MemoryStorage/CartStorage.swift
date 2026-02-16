import Foundation

protocol CartStoring {
    func isInCart(id: String) -> Bool
    func setInCart(_ inCart: Bool, id: String)
    func toggle(id: String)
    func allIds() -> Set<String>
    func setAllIds(_ ids: Set<String>)
}

final class CartStorage: CartStoring {

    static let shared = CartStorage()

    private let key = "cart_nft_ids"
    private let defaults = UserDefaults.standard

    private init() {}

    func isInCart(id: String) -> Bool {
        allIds().contains(id)
    }

    func setInCart(_ inCart: Bool, id: String) {
        var ids = allIds()
        if inCart {
            ids.insert(id)
        } else {
            ids.remove(id)
        }
        setAllIds(ids)
    }

    func toggle(id: String) {
        setInCart(!isInCart(id: id), id: id)
    }

    func allIds() -> Set<String> {
        Set(defaults.stringArray(forKey: key) ?? [])
    }

    func setAllIds(_ ids: Set<String>) {
        defaults.set(Array(ids), forKey: key)
    }
}

