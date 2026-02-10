import Foundation

enum CartViewState {
    case idle
    case loading
    case loadingPlaceholders(items: [UICartItem])
    case loaded(items: [UICartItem], total: Double)
    case empty
    case error(message: String)
}

protocol CartViewModelProtocol: AnyObject {
    var sortOption: SortOption { get set }
    var state: CartViewState { get }
    var onStateChange: ((CartViewState) -> Void)? { get set }
    var itemsCount: Int { get }
    var totalItemsCount: Int { get }
    var totalPrice: Double { get }

    func loadItems()
    func deleteItem(at index: Int)
    func addItem(id: String)
    func sortItems()
    func getUICartItem(at index: Int) -> UICartItem?
    func isEmpty() -> Bool
    func updateSearchQuery(_ query: String)
}
