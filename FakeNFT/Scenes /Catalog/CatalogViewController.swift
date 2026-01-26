import UIKit

final class CatalogViewController: UIViewController {
    
    // MARK: - Properties
    private let viewModel: CatalogViewModel
    
    // MARK: - UI Elements
    private lazy var tableView: UITableView = {
        let tableView = UITableView(frame: .zero, style: .plain)
        tableView.backgroundColor = UIColor(resource: .nftWhite)
        tableView.register(CatalogCollectionCell.self, forCellReuseIdentifier: "CatalogCollectionCell")
        tableView.separatorStyle = .none
        tableView.rowHeight = 75
        tableView.translatesAutoresizingMaskIntoConstraints = false
        return tableView
    }()
    
    // MARK: - Initializer
    init(viewModel: CatalogViewModel) {
        self.viewModel = viewModel
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
        bindViewModel()
    }
    
    // MARK: - Private Methods
    private func setupUI() {
        view.backgroundColor = UIColor(resource: .nftWhite)
        
        view.addSubview(tableView)
        
        tableView.dataSource = self
        tableView.delegate = self
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 16),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.topAnchor, constant: -16)
        ])
    }
    
    private func bindViewModel() {
        
    }
    
}

//MARK: - UITableViewDataSource
extension CatalogViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        <#code#>
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        <#code#>
    }
    
}

//MARK: - UITableViewDelegate
extension CatalogViewController: UITableViewDelegate {
    
}
