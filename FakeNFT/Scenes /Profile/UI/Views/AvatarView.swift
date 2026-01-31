import UIKit

final class AvatarView: UIImageView {
    
    override func layoutSubviews() {
        super.layoutSubviews()
        layer.masksToBounds = true
        layer.cornerRadius = min(bounds.width, bounds.height) / 2
    }
    
}
