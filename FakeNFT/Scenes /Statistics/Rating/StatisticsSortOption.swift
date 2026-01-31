import Foundation

enum StatisticsSortOption: Equatable {
    case name
    case rating

    var title: String {
        switch self {
        case .name:
            return "По имени"
        case .rating:
            return "По рейтингу"
        }
    }
}

