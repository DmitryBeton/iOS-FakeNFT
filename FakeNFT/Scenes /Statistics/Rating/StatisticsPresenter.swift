import Foundation

protocol StatisticsPresenterProtocol: AnyObject {
    var onDataUpdated: (() -> Void)? { get set }
    var onLoadingChanged: ((Bool) -> Void)? { get set }
    var onError: ((String) -> Void)? { get set }

    var usersCount: Int { get }

    func viewDidLoad()
    func user(at index: Int) -> StatisticsUserCellModel
    func sort(by option: StatisticsSortOption)
}

final class StatisticsPresenter: StatisticsPresenterProtocol {

    var onDataUpdated: (() -> Void)?
    var onLoadingChanged: ((Bool) -> Void)?
    var onError: ((String) -> Void)?

    private struct User {
        let name: String
        let value: Int 
        let avatarURL: String
    }

    private let service: StatisticsServiceProtocol

    private var users: [User] = []
    private var sortOption: StatisticsSortOption = .rating

    init(service: StatisticsServiceProtocol = StatisticsService()) {
        self.service = service
    }

    var usersCount: Int { users.count }

    func viewDidLoad() {
        onLoadingChanged?(true)

        service.fetchUsers { [weak self] result in
            guard let self else { return }

            switch result {
            case .success(let dto):
                let mapped = dto.map {
                    User(name: $0.name, value: $0.rating, avatarURL: $0.avatar)
                }

                self.users = mapped

                DispatchQueue.main.async {
                    self.onLoadingChanged?(false)
                    self.onDataUpdated?()
                }
                
            case .failure(let error):
                print("Statistics load error:", error)
                DispatchQueue.main.async {
                    self.onLoadingChanged?(false)
                    self.onError?("Не удалось загрузить статистику: \(error)")
                }

            }
        }
    }

    func user(at index: Int) -> StatisticsUserCellModel {
        let sorted = sortedUsers()
        let user = sorted[index]
        return .init(place: index + 1, name: user.name, nftCount: user.value)
    }

    func sort(by option: StatisticsSortOption) {
        sortOption = option
        onDataUpdated?()
    }

    private func sortedUsers() -> [User] {
        switch sortOption {
        case .name:
            return users.sorted { $0.name.localizedCaseInsensitiveCompare($1.name) == .orderedAscending }
        case .rating:
            return users.sorted { $0.value > $1.value }
        }
    }
}

