import Foundation

protocol LikesStoring {
    func isLiked(id: String) -> Bool
    func setLiked(_ liked: Bool, id: String)
    func allLikedIds() -> Set<String>
    func setAllLikedIds(_ ids: Set<String>)
}

final class LikesStorage: LikesStoring {
    private let key = "liked_nft_ids"
    private let defaults = UserDefaults.standard

    func isLiked(id: String) -> Bool {
        allLikedIds().contains(id)
    }

    func setLiked(_ liked: Bool, id: String) {
        var ids = allLikedIds()
        if liked { ids.insert(id) } else { ids.remove(id) }
        setAllLikedIds(ids)
    }

    func allLikedIds() -> Set<String> {
        Set(defaults.stringArray(forKey: key) ?? [])
    }

    func setAllLikedIds(_ ids: Set<String>) {
        defaults.set(Array(ids), forKey: key)
    }
}

