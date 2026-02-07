import UIKit

final class MyNftViewController: UIViewController {
    
    // MARK: - Private Types
    
    private enum Section {
        case main
    }
    
    // MARK: - Views
    
    private lazy var nftTableView: UITableView = {
        let tableView = UITableView(frame: .zero, style: .grouped)
        tableView.separatorStyle = .none
        tableView.register(MyNftCell.self)
        tableView.backgroundColor = .clear
        tableView.rowHeight = 140
        return tableView
    }()
    
    private lazy var emptyLabel: UILabel = {
        let label = UILabel()
        label.font = .bodyBold
        label.textColor = UIColor(resource: .nftBlack)
        label.text = Localization.MyNft.empty
        label.isHidden = true
        return label
    }()
    
    private lazy var sortBarButtonItem = UIBarButtonItem(
        image: UIImage(resource: .prSort),
        style: .plain,
        target: self,
        action: nil
    )
    
    // MARK: - DiffableDataSource
    
    private lazy var dataSource: UITableViewDiffableDataSource<Section, MyNftUI> = {
        let dataSource = UITableViewDiffableDataSource<Section, MyNftUI>(
            tableView: nftTableView
        ) { [weak self] tableView, indexPath, nft in
            let cell: MyNftCell = tableView.dequeueReusableCell()
            cell.configure(nft: nft)
            cell.onLikeTap = {
                self?.viewModel.setLike(id: nft.id)
            }
            return cell
        }
        return dataSource
    }()
    
    // MARK: - Private Properties
    
    private let viewModel: MyNftViewModelProtocol
    
    // MARK: - Init
    
    init(viewModel: MyNftViewModelProtocol) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        assertionFailure("init(coder:) has not been implemented")
        return nil
    }
    
    // MARK: - Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
        setupNavigationBar()
        setupConstraints()
        setupDelegates()
        applySnapshot(nfts: [], animating: false)
        bind()
        viewModel.loadNfts()
    }
    
    // MARK: - UI Methods
    
    private func setupViews() {
        view.backgroundColor = UIColor(resource: .nftWhite)
        view.addSubviews([
            nftTableView,
            emptyLabel
        ])
    }
    
    private func setupNavigationBar() {
        navigationItem.rightBarButtonItem = sortBarButtonItem
        navigationItem.title = Localization.MyNft.title
    }
    
    private func setupConstraints() {
        [nftTableView].disableAutoresizingMasks()
        
        NSLayoutConstraint.activate([
            nftTableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            nftTableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            nftTableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            nftTableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
        
        emptyLabel.constraintCenters(to: view)
    }
    
    // MARK: - Private Methods
    
    private func setupDelegates() {
        nftTableView.delegate = self
    }
    
    private func applySnapshot(nfts: [MyNftUI], animating: Bool) {
        var snapshot = NSDiffableDataSourceSnapshot<Section, MyNftUI>()
        snapshot.appendSections([.main])
        snapshot.appendItems(nfts, toSection: .main)
        dataSource.apply(snapshot, animatingDifferences: animating)
    }
    
    private func updateEmptyState() {
        let isEmpty = viewModel.sortedNfts.isEmpty
        nftTableView.isHidden = isEmpty
        emptyLabel.isHidden = !isEmpty
    }
    
    private func bind() {
        viewModel.onStateChange = { [weak self] state in
            guard let self else { return }
            DispatchQueue.main.async {
                switch state {
                case .initial:
                    UIBlockingProgressHUD.dismiss()
                    assertionFailure("can't move to initial state")
                    
                case .loading:
                    UIBlockingProgressHUD.show()
                    
                case .data:
                    UIBlockingProgressHUD.dismiss()
                    let nfts = self.viewModel.sortedNfts
                    self.applySnapshot(nfts: nfts, animating: true)
                    self.updateEmptyState()
                    
                case .failed:
                    UIBlockingProgressHUD.dismiss()
                    break
                }
            }
        }
        viewModel.onSortChange = { [weak self] in
            guard let self else { return }
            DispatchQueue.main.async {
                let nfts = self.viewModel.sortedNfts
                self.applySnapshot(nfts: nfts, animating: true)
            }
        }
        viewModel.onLikesUpdate = { [weak self] in
            guard let self else { return }
            DispatchQueue.main.async {
                let nfts = self.viewModel.sortedNfts
                self.applySnapshot(nfts: nfts, animating: false)
            }
        }
    }
    
}

// MARK: - TableViewDelegate

extension MyNftViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        UIView()
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        20
    }
    
}
