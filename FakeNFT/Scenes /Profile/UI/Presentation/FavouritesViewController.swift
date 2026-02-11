import UIKit

final class FavouritesViewController: UIViewController, NetworkErrorView {
    
    // MARK: - Private Types
    
    private enum Section {
        case main
    }
    
    // MARK: - Views
    
    private lazy var favouritesCollectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.register(FavouriteCell.self)
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
            return cell
        }
        return dataSource
    }()
    
    // MARK: - Private Properties
    
    private let mockNfts: [FavouriteNftUI] = [
        FavouriteNftUI(
            name: "commodo porttitor",
            image: URL(string: "https://code.s3.yandex.net/Mobile/iOS/NFT/Beige/April/1.png"),
            rating: 3,
            price: "36.54",
            id: UUID(),
            isLiked: true
        ),
        FavouriteNftUI(
            name: "commodo porttitor",
            image: URL(string: "https://code.s3.yandex.net/Mobile/iOS/NFT/Beige/April/1.png"),
            rating: 3,
            price: "36.54",
            id: UUID(),
            isLiked: true
        ),
        FavouriteNftUI(
            name: "commodo porttitor",
            image: URL(string: "https://code.s3.yandex.net/Mobile/iOS/NFT/Beige/April/1.png"),
            rating: 3,
            price: "36.54",
            id: UUID(),
            isLiked: false
        ),
        FavouriteNftUI(
            name: "commodo porttitor",
            image: URL(string: "https://code.s3.yandex.net/Mobile/iOS/NFT/Beige/April/1.png"),
            rating: 3,
            price: "36.54",
            id: UUID(),
            isLiked: false
        ),
    ]
    
    // MARK: - Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
        setupNavigationBar()
        setupConstraints()
        applySnapshot(nfts: mockNfts, animating: false)
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
    
}
