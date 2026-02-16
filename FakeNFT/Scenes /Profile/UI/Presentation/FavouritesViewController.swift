import UIKit
import ProgressHUD

final class FavouritesViewController: UIViewController, NetworkErrorView {
    
    // MARK: - Private Types
    
    private enum Section {
        case main
    }
    
    // MARK: - Views
    
    private lazy var favouritesCollectionView: UICollectionView = {
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.register(FavouriteCell.self)
        collectionView.backgroundColor = .clear
        return collectionView
    }()
    
    private lazy var emptyLabel: UILabel = {
        let label = UILabel()
        label.font = .bodyBold
        label.textColor = UIColor(resource: .nftBlack)
        label.text = Localization.Favourites.empty
        label.isHidden = true
        return label
    }()
    
    // MARK: - DiffableDataSource
    
    private lazy var dataSource: UICollectionViewDiffableDataSource<Section, FavouriteNftUI> = {
        let dataSource = UICollectionViewDiffableDataSource<Section, FavouriteNftUI>(
            collectionView: favouritesCollectionView
        ) { [weak self] collectionView, indexPath, nft in
            let cell: FavouriteCell = collectionView.dequeueReusableCell(indexPath: indexPath)
            cell.configure(nft: nft)
            cell.onLikeTap = {
                self?.viewModel.setLike(id: nft.id)
            }
            return cell
        }
        return dataSource
    }()
    
    // MARK: - Private Properties
    
    private let viewModel: FavouritesViewModelProtocol
    
    private let layout = GridFlowLayout(
        columns: 2,
        cellSpacing: 7,
        lineSpacing: 20,
        insets: UIEdgeInsets(top: 20, left: 16, bottom: 0, right: 16),
        height: 80
    )
    
    // MARK: - Init
    
    init(viewModel: FavouritesViewModelProtocol) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    @available(*, unavailable)
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
        applySnapshot(nfts: [], animating: false)
        bind()
        viewModel.loadNfts()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        ProgressHUD.dismiss()
    }
    
    // MARK: - UI Methods
    
    private func setupViews() {
        view.backgroundColor = UIColor(resource: .nftWhite)
        view.addSubviews([
            favouritesCollectionView,
            emptyLabel
        ])
    }
    
    private func setupNavigationBar() {
        navigationItem.title = Localization.Favourites.title
    }
    
    private func setupConstraints() {
        [favouritesCollectionView].disableAutoresizingMasks()
        
        NSLayoutConstraint.activate([
            favouritesCollectionView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            favouritesCollectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            favouritesCollectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            favouritesCollectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
        
        emptyLabel.constraintCenters(to: view)
    }
    
    // MARK: - Private Methods
    
    private func applySnapshot(nfts: [FavouriteNftUI], animating: Bool) {
        var snapshot = NSDiffableDataSourceSnapshot<Section, FavouriteNftUI>()
        snapshot.appendSections([.main])
        snapshot.appendItems(nfts, toSection: .main)
        dataSource.apply(snapshot, animatingDifferences: animating)
    }
    
    private func bind() {
        viewModel.onStateChange = { [weak self] state in
            guard let self else { return }
            
            DispatchQueue.main.async {
                switch state {
                case .initial:
                    ProgressHUD.dismiss()
                    assertionFailure("can't move to initial state")
                    
                case .loading:
                    ProgressHUD.show()
                    
                case .data:
                    ProgressHUD.dismiss()
                    let nfts = self.viewModel.nftsUI
                    self.applySnapshot(nfts: nfts, animating: true)
                    self.updateEmptyState()
                    
                case .failed:
                    ProgressHUD.dismiss()
                    self.showNetworkError() {
                        self.viewModel.loadNfts()
                    }
                }
            }
        }
        viewModel.onLikesUpdate = { [weak self] in
            guard let self else { return }
            
            DispatchQueue.main.async {
                let nftsUI = self.viewModel.nftsUI
                self.applySnapshot(nfts: nftsUI, animating: true)
                self.updateEmptyState()
            }
        }
    }
    
    private func updateEmptyState() {
        let isEmpty = viewModel.nftsUI.isEmpty
        favouritesCollectionView.isHidden = isEmpty
        emptyLabel.isHidden = !isEmpty
    }
    
}
