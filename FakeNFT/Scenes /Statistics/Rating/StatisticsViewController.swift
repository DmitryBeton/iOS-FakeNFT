import UIKit

final class StatisticsViewController: UIViewController {
    
    private let viewModel: StatisticsViewModelProtocol
    private let tableView = UITableView()
    private var sortOption: StatisticsSortOption = .rating
    private var imageTasks: [IndexPath: UUID] = [:]
    private let servicesAssembly: ServicesAssembly
    
    private let loader = UIActivityIndicatorView(style: .medium)

    init(viewModel: StatisticsViewModelProtocol, servicesAssembly: ServicesAssembly) {
        self.viewModel = viewModel
        self.servicesAssembly = servicesAssembly
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) { nil }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupTableView()
        setupLoader()
        bindPresenter()
        viewModel.viewDidLoad()
    }
    
    private func setupUI() {
        view.backgroundColor = .systemBackground
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            image: UIImage(named: "statisticSort"),
            style: .plain,
            target: self,
            action: #selector(sortTapped)
        )
    }
    
    private func setupTableView() {
        view.addSubview(tableView)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.delegate = self
        
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
        ])
        
        tableView.dataSource = self
        tableView.backgroundColor = .systemBackground
        tableView.showsVerticalScrollIndicator = false
        tableView.separatorStyle = .none
        tableView.contentInset = UIEdgeInsets(top: 16, left: 0, bottom: 16, right: 0)
        
        tableView.register(
            StatisticsUserCell.self,
            forCellReuseIdentifier: StatisticsUserCell.reuseId
        )
        
        tableView.tableFooterView = UIView()
    }
    
    private func setupLoader() {
        loader.hidesWhenStopped = true
        loader.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(loader)
        
        NSLayoutConstraint.activate([
            loader.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            loader.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
    }
    
    private func bindPresenter() {
        viewModel.onDataUpdated = { [weak self] in
            DispatchQueue.main.async {
                self?.tableView.reloadData()
            }
        }
        
        viewModel.onLoadingChanged = { [weak self] isLoading in
            DispatchQueue.main.async {
                if isLoading {
                    self?.loader.startAnimating()
                } else {
                    self?.loader.stopAnimating()
                }
            }
        }
        
        viewModel.onError = { [weak self] message in
            DispatchQueue.main.async {
                let alert = UIAlertController(title: "Ошибка", message: message, preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "ОК", style: .default))
                self?.present(alert, animated: true)
            }
        }
        
        viewModel.onUserSelected = { [weak self] userId in
            guard let self else { return }
            let vc = UserCardModule.make(userId: userId, servicesAssembly: self.servicesAssembly)
            vc.hidesBottomBarWhenPushed = true
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }
    
    @objc private func sortTapped() {
        let alert = UIAlertController(
            title: "Сортировка",
            message: nil,
            preferredStyle: .actionSheet
        )

        let nameTitle = (sortOption == .name) ? "По имени" : "По имени"
        alert.addAction(UIAlertAction(title: nameTitle, style: .default) { [weak self] _ in
            guard let self else { return }
            self.sortOption = .name
            self.viewModel.sort(by: .name)
        })

        let ratingTitle = (sortOption == .rating) ? "По рейтингу" : "По рейтингу"
        alert.addAction(UIAlertAction(title: ratingTitle, style: .default) { [weak self] _ in
            guard let self else { return }
            self.sortOption = .rating
            self.viewModel.sort(by: .rating)
        })

        alert.addAction(UIAlertAction(title: "Отмена", style: .cancel))

        present(alert, animated: true)
    }
}

extension StatisticsViewController: UITableViewDataSource {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        viewModel.usersCount
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(
            withIdentifier: StatisticsUserCell.reuseId,
            for: indexPath
        ) as? StatisticsUserCell else { return UITableViewCell() }

        let model = viewModel.getUser(at: indexPath.row)
        cell.configure(with: model)

        guard let url = URL(string: model.avatarURL) else { return cell }

        let taskId = ImageLoader.shared.load(url) { [weak self] image in
            DispatchQueue.main.async {
                guard let self else { return }

                guard
                    let visibleCell = self.tableView.cellForRow(at: indexPath) as? StatisticsUserCell,
                    visibleCell.currentAvatarURLString == model.avatarURL
                else { return }

                visibleCell.setAvatarImage(image)
            }
        }

        imageTasks[indexPath] = taskId
        return cell

    }
}

extension StatisticsViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        viewModel.selectUser(at: indexPath.row)
    }
}
