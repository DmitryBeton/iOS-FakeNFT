import Foundation

protocol FavoritesStorage {
    func isFavorite(nftId: String) -> Bool
    func addFavorite(nftId: String)
    func removeFavorite(nftId: String)
    func toggleFavorite(nftId: String) -> Bool
    func getAllFavorites() -> [String]
}

final class FavoritesStorageImpl: FavoritesStorage {

    static let shared = FavoritesStorageImpl()

    private let userDefaults = UserDefaults.standard
    private let favoritesKey = "FavoriteNFTs"

    private init() {}

    func isFavorite(nftId: String) -> Bool {
        let favorites = getAllFavorites()
        return favorites.contains(nftId)
    }

    func addFavorite(nftId: String) {
        var favorites = getAllFavorites()
        guard !favorites.contains(nftId) else { return }
        favorites.append(nftId)
        saveFavorites(favorites)
    }

    func removeFavorite(nftId: String) {
        var favorites = getAllFavorites()
        favorites.removeAll { $0 == nftId }
        saveFavorites(favorites)
    }

    func toggleFavorite(nftId: String) -> Bool {
        if isFavorite(nftId: nftId) {
            removeFavorite(nftId: nftId)
            return false
        } else {
            addFavorite(nftId: nftId)
            return true
        }
    }

    func getAllFavorites() -> [String] {
        return userDefaults.stringArray(forKey: favoritesKey) ?? []
    }

    private func saveFavorites(_ favorites: [String]) {
        userDefaults.set(favorites, forKey: favoritesKey)
    }
}
