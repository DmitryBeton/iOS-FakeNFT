import UIKit

final class GridFlowLayout: UICollectionViewFlowLayout {
    
    // MARK: - Private Properties
    
    private let columns: Int
    private let height: CGFloat
    
    // MARK: - Init
    
    init(columns: Int, cellSpacing: CGFloat, lineSpacing: CGFloat, insets: UIEdgeInsets, height: CGFloat) {
        self.columns = columns
        self.height = height
        super.init()
        minimumInteritemSpacing = cellSpacing
        minimumLineSpacing = lineSpacing
        sectionInset = insets
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        assertionFailure("init(coder:) has not been implemented")
        return nil
    }
    
    // MARK: - Overrides
    
    override func prepare() {
        super.prepare()
        guard let collectionView else { return }
        
        let totalSpacing = minimumInteritemSpacing * CGFloat(columns - 1)
        let totalInsets = sectionInset.left + sectionInset.right
        let width = (collectionView.bounds.width - totalSpacing - totalInsets) / CGFloat(columns)
        
        itemSize = CGSize(width: width, height: height)
    }
    
}
