import Foundation


final class StatisticsViewModel: StatisticsViewModelProtocol {

    var onUserSelected: ((String) -> Void)?

    var onDataUpdated: (() -> Void)?
    var onLoadingChanged: ((Bool) -> Void)?
    var onError: ((String) -> Void)?

    private let service: StatisticsServiceProtocol
    private let mapper: StatisticsUsersMapperProtocol
    private let sorter: StatisticsUsersSorterProtocol
    private let sortStorage: StatisticsSortOptionStorageProtocol

    private var users: [StatisticsUserDomain] = []
    private var sorted: [StatisticsUserDomain] = []
    private var sortOption: StatisticsSortOption

    init(
        service: StatisticsServiceProtocol = StatisticsService(),
        mapper: StatisticsUsersMapperProtocol = StatisticsUsersMapper(),
        sorter: StatisticsUsersSorterProtocol = StatisticsUsersSorter(),
        sortStorage: StatisticsSortOptionStorageProtocol = StatisticsSortOptionStorage()
    ) {
        self.service = service
        self.mapper = mapper
        self.sorter = sorter
        self.sortStorage = sortStorage
        self.sortOption = sortStorage.load()
    }

    var usersCount: Int { sorted.count }
    
    func selectUser(at index: Int) {
        let user = sorted[index]
        onUserSelected?(user.id)
    }

    func currentSortOption() -> StatisticsSortOption { sortOption }

    func viewDidLoad() {
        onLoadingChanged?(true)

        service.fetchUsers { [weak self] result in
            guard let self else { return }

            switch result {
            case .success(let dto):
                let mapped = self.mapper.map(dto)
                self.users = mapped
                self.applySort()

                DispatchQueue.main.async {
                    self.onLoadingChanged?(false)
                    self.onDataUpdated?()
                }

            case .failure(let error):
                //AppLog.ui.error("Statistics load error: \(error.localizedDescription, privacy: .public)")
                DispatchQueue.main.async {
                    self.onLoadingChanged?(false)
                    self.onError?("Не удалось загрузить статистику")
                }
            }
        }
    }

    func getUser(at index: Int) -> StatisticsUserCellModel {
        let user = sorted[index]
        let rowVM = StatisticsUserRowViewModel(user: user, place: index + 1)
        return rowVM.makeCellModel()
    }

    func sort(by option: StatisticsSortOption) {
        sortOption = option
        sortStorage.save(option)
        applySort()
        onDataUpdated?()
    }

    private func applySort() {
        sorted = sorter.sort(users, by: sortOption)
    }
}

