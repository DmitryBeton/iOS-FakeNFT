enum StatisticsSortOption: String, CaseIterable {
    case rating
    case name

    var title: String {
        switch self {
        case .rating: return "По рейтингу"
        case .name: return "По имени"
        }
    }
}

