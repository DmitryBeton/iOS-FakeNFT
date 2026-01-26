import Foundation

protocol StatisticsPresenterProtocol: AnyObject {
    var onDataUpdated: (() -> Void)? { get set }
    var usersCount: Int { get }

    func viewDidLoad()
    func user(at index: Int) -> StatisticsUserCellModel
    func sort(by option: StatisticsSortOption)
}

final class StatisticsPresenter: StatisticsPresenterProtocol {

    var onDataUpdated: (() -> Void)?

    private struct User {
        let name: String
        let nftCount: Int
    }

    private var users: [User] = []
    private var sortOption: StatisticsSortOption = .rating

    var usersCount: Int {
        users.count
    }

    func viewDidLoad() {
        // мок-данные, чтобы закрыть UI-issues
        users = [
            .init(name: "Alex", nftCount: 112),
            .init(name: "Bill", nftCount: 98),
            .init(name: "Alla", nftCount: 72),
            .init(name: "Mads", nftCount: 71),
            .init(name: "Timothée", nftCount: 51),
            .init(name: "Lea", nftCount: 23),
            .init(name: "Eric", nftCount: 11)
        ]

        applySort(option: sortOption)
    }

    func user(at index: Int) -> StatisticsUserCellModel {
        let sorted = sortedUsers()
        let user = sorted[index]
        return .init(place: index + 1, name: user.name, nftCount: user.nftCount)
    }

    func sort(by option: StatisticsSortOption) {
        sortOption = option
        applySort(option: option)
    }

    private func applySort(option: StatisticsSortOption) {
        // сортировка влияет только на порядок отображения.
        // данные не мутируем, чтобы можно было легко менять порядок снова.
        onDataUpdated?()
    }

    private func sortedUsers() -> [User] {
        switch sortOption {
        case .name:
            return users.sorted { $0.name.localizedCaseInsensitiveCompare($1.name) == .orderedAscending }
        case .rating:
            return users.sorted { $0.nftCount > $1.nftCount }
        }
    }
}

