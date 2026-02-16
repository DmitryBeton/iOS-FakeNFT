import Foundation

final class SortOptionStorage: SortOptionStorageProtocol {
    
    // MARK: - Public Properties
    
    var sortOption: ProfileSortOption {
        get {
            guard let rawValue = defaults.string(forKey: key),
                  let option = ProfileSortOption(rawValue: rawValue)
            else { return .rating }
            return option
        }
        set {
            defaults.set(newValue.rawValue, forKey: key)
        }
    }
    
    // MARK: - Private Properties
    
    private let key = "nft_sort_option"
    private let defaults = UserDefaults.standard
    
}
