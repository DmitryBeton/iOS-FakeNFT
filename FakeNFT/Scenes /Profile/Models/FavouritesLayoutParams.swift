import UIKit

struct FavouritesLayoutParams {
    let cellCount: Int
    let cellHeight: CGFloat
    let insets: UIEdgeInsets
    let cellSpacing: CGFloat
    let lineSpacing: CGFloat
    let paddingWidth: CGFloat
    
    init(
        cellCount: Int,
        cellHeight: CGFloat,
        insets: UIEdgeInsets,
        cellSpacing: CGFloat,
        lineSpacing: CGFloat
    ) {
        self.cellCount = cellCount
        self.cellHeight = cellHeight
        self.insets = insets
        self.cellSpacing = cellSpacing
        self.lineSpacing = lineSpacing
        self.paddingWidth = insets.left + insets.right + CGFloat(cellCount - 1) * cellSpacing
    }
}
