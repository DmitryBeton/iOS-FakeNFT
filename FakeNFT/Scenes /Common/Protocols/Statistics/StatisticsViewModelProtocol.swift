protocol StatisticsViewModelProtocol: AnyObject {
    var onDataUpdated: (() -> Void)? { get set }
    var onLoadingChanged: ((Bool) -> Void)? { get set }
    var onError: ((String) -> Void)? { get set }

    var usersCount: Int { get }

    func viewDidLoad()
    func getUser(at index: Int) -> StatisticsUserCellModel
    func sort(by option: StatisticsSortOption)
    func currentSortOption() -> StatisticsSortOption
}

