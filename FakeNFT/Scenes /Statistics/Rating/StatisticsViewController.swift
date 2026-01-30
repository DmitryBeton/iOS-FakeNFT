import UIKit

final class StatisticsViewController: UIViewController {
    
    private let presenter: StatisticsPresenterProtocol
    private let tableView = UITableView()
    private var sortOption: StatisticsSortOption = .rating
    
    private let loader = UIActivityIndicatorView(style: .medium)
    
    init(presenter: StatisticsPresenterProtocol) {
        self.presenter = presenter
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupTableView()
        setupLoader()
        bindPresenter()
        presenter.viewDidLoad()
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
        presenter.onDataUpdated = { [weak self] in
            DispatchQueue.main.async {
                self?.tableView.reloadData()
            }
        }
        
        presenter.onLoadingChanged = { [weak self] isLoading in
            DispatchQueue.main.async {
                if isLoading {
                    self?.loader.startAnimating()
                } else {
                    self?.loader.stopAnimating()
                }
            }
        }
        
        presenter.onError = { [weak self] message in
            DispatchQueue.main.async {
                let alert = UIAlertController(title: "Ошибка", message: message, preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "ОК", style: .default))
                self?.present(alert, animated: true)
            }
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
            self.presenter.sort(by: .name)
        })

        let ratingTitle = (sortOption == .rating) ? "По рейтингу" : "По рейтингу"
        alert.addAction(UIAlertAction(title: ratingTitle, style: .default) { [weak self] _ in
            guard let self else { return }
            self.sortOption = .rating
            self.presenter.sort(by: .rating)
        })

        alert.addAction(UIAlertAction(title: "Отмена", style: .cancel))

        present(alert, animated: true)
    }
}

extension StatisticsViewController: UITableViewDataSource {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        presenter.usersCount
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(
            withIdentifier: StatisticsUserCell.reuseId,
            for: indexPath
        ) as? StatisticsUserCell else { return UITableViewCell() }

        cell.configure(with: presenter.user(at: indexPath.row))
        return cell
    }
}

