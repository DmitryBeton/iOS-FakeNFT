import Foundation

final class SortOptionStorage: SortOptionStorageProtocol {
    
    // MARK: - Public Properties
    
    var sortOption: SortOption {
        get {
            guard let rawValue = defaults.string(forKey: key),
                  let option = SortOption(rawValue: rawValue)
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
