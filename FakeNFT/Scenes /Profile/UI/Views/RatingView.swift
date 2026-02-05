import UIKit

final class RatingView: UIStackView {
    
    // MARK: - Public Properties
    
    var rating: Int = 0 {
        didSet {
            setRating()
        }
    }
    
    // MARK: - Private Properties
    
    private let maxRating = 5
    private let starImage = UIImage(resource: .prRating)
    private let emptyStarImage = UIImage(resource: .prRatingEmpty)
    
    // MARK: - Init
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
    }
    
    required init(coder: NSCoder) {
        assertionFailure("init(coder:) has not been implemented")
        super.init(coder: coder)
    }
    
    // MARK: - UI Methods
    
    private func setupViews() {
        axis = .horizontal
        spacing = 2
        alignment = .center
        
        for _ in 0..<maxRating {
            let imageView = UIImageView()
            addArrangedSubview(imageView)
        }
        setRating()
    }
    
    // MARK: - Private Methods
    
    private func setRating() {
        for (index, view) in arrangedSubviews.enumerated() {
            guard let imageView = view as? UIImageView else { continue }
            imageView.image = index < rating ? starImage : emptyStarImage
        }
    }
    
}
