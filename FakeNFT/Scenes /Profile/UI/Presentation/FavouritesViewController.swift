import UIKit

final class FavouritesViewController: UIViewController, NetworkErrorView {
    
    // MARK: - Views
    
    private lazy var favouritesCollectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        return collectionView
    }()
    
    private lazy var emptyLabel: UILabel = {
        let label = UILabel()
        label.font = .bodyBold
        label.textColor = UIColor(resource: .nftBlack)
        label.text = "У Вас ещё нет избранных NFT"
        label.isHidden = true
        return label
    }()
    
    // MARK: - Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    // MARK: - UI Methods
    
    private func setupViews() {
        
    }
    
}
