import UIKit

final class CatalogViewController: UIViewController {

    // MARK: - Properties

    private let viewModel: CatalogViewModel
    private let servicesAssembly: ServicesAssembly
    
    // MARK: - UI Elements
    
    private lazy var tableView: UITableView = {
        let tableView = UITableView(frame: .zero, style: .plain)
        tableView.backgroundColor = UIColor(resource: .nftWhite)
        tableView.separatorStyle = .none
        tableView.register(CatalogCollectionCell.self, forCellReuseIdentifier: CatalogCollectionCell.reuseIdentifier)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        return tableView
    }()
    
    private lazy var activityIndicator: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView(style: .large)
        indicator.translatesAutoresizingMaskIntoConstraints = false
        return indicator
    }()
    
    // MARK: - Initializer

    init(servicesAssembly: ServicesAssembly) {
        self.servicesAssembly = servicesAssembly
        self.viewModel = CatalogViewModel(collectionService: servicesAssembly.collectionService)
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
        setupConstraints()
        setupNavigationBar()
        bindViewModel()
        
        viewModel.viewDidLoad()
    }
    
    // MARK: - Private Methods
    
    private func setupUI() {
        view.backgroundColor = UIColor(resource: .nftWhite)

        view.addSubview(tableView)
        view.addSubview(activityIndicator)

        tableView.dataSource = self
        tableView.delegate = self
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 12),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor),

            activityIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            activityIndicator.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
    }
    
    private func setupNavigationBar() {
        let sortButton = UIBarButtonItem(
            image: UIImage(resource: .catalogSort),
            style: .plain,
            target: self,
            action: #selector(sortButtonTapped)
        )
        sortButton.tintColor = UIColor(resource: .nftBlack)
        navigationItem.rightBarButtonItem = sortButton
    }
    
    // MARK: - ViewModel Binding
    
    private func bindViewModel() {
        // Когда коллекции обновляются - перезагружаем таблицу
        viewModel.onCollectionsUpdated = { [weak self] _ in
            DispatchQueue.main.async {
                self?.tableView.reloadData()
            }
        }
        
        // Когда меняется состояние загрузки - показываем/скрываем индикатор
        viewModel.onLoadingStateChanged = { [weak self] isLoading in
            DispatchQueue.main.async {
                if isLoading {
                    self?.activityIndicator.startAnimating()
                } else {
                    self?.activityIndicator.stopAnimating()
                }
            }
        }
        
        viewModel.onError = { [weak self] errorMessage in
            DispatchQueue.main.async {
                print("Error: \(errorMessage)")
            }
        }
    }
    
    // MARK: - Actions
    
    @objc private func sortButtonTapped() {
        let alert = UIAlertController(title: Localization.Catalog.sortBy.localized,
                                      message: nil,
                                      preferredStyle: .actionSheet)

        alert.addAction(UIAlertAction(title: Localization.Catalog.sortByName.localized, style: .default) { [weak self] _ in
            self?.viewModel.sortCollections(by: .byName)
        })

        alert.addAction(UIAlertAction(title: Localization.Catalog.sortByNumberOfNFTs.localized, style: .default) { [weak self] _ in
            self?.viewModel.sortCollections(by: .byNftCount)
        })

        alert.addAction(UIAlertAction(title: Localization.Catalog.cancel.localized, style: .cancel))

        present(alert, animated: true)
    }
}

//MARK: - UITableViewDataSource

extension CatalogViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.numberOfCollections()
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(
            withIdentifier: CatalogCollectionCell.reuseIdentifier,
            for: indexPath
        ) as? CatalogCollectionCell else {
            return UITableViewCell()
        }

        let collection = viewModel.collection(at: indexPath.row)
        cell.configure(with: collection)

        return cell
    }

}

//MARK: - UITableViewDelegate

extension CatalogViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 187
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)

        let collection = viewModel.collection(at: indexPath.row)
        let detailViewController = CollectionDetailViewController(
            collectionId: collection.id,
            collectionName: collection.name
        )
        navigationController?.pushViewController(detailViewController, animated: true)
    }
}
