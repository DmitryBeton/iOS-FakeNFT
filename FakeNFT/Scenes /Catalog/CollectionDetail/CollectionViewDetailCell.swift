import UIKit

final class CollectionViewDetailCell: UICollectionViewCell {
    
    // MARK: - Properties
    private static let reuseIdentifier = "CollectionViewDetailCell"
    
    // MARK: - Initialization
    override init(frame: CGRect) {
        super.init(frame: frame)
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
