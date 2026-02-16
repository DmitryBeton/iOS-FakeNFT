import Foundation

protocol StatisticsSortOptionStorageProtocol {
    func load() -> StatisticsSortOption
    func save(_ option: StatisticsSortOption)
}

final class StatisticsSortOptionStorage: StatisticsSortOptionStorageProtocol {
    private enum Keys {
        static let sortKey = "statistics.sort.option"
    }

    func load() -> StatisticsSortOption {
        let raw = UserDefaults.standard.string(forKey: Keys.sortKey)
        return StatisticsSortOption(rawValue: raw ?? "") ?? .rating
    }

    func save(_ option: StatisticsSortOption) {
        UserDefaults.standard.set(option.rawValue, forKey: Keys.sortKey)
    }
}

