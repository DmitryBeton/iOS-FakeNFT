import UIKit
import Kingfisher

final class FavouriteCell: UICollectionViewCell, ReuseIdentifying {
    
    // MARK: - Bindings
    
    var onLikeTap: (() -> Void)?
    
    // MARK: - Public Methods
    
    func configure(nft: FavouriteNftUI) {
        nameLabel.text = nft.name
        nftImageView.kf.setImage(with: nft.image)
        ratingView.rating = nft.rating
        priceLabel.text = "\(nft.price) ETH"
        isLiked = nft.isLiked
    }
    
    // MARK: - Private Types
    
    private enum Constants {
        enum Layout {
            
        }
        enum Spacing {
            
        }
    }
    
    // MARK: - Views
    
    private lazy var nftImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.layer.masksToBounds = true
        imageView.layer.cornerRadius = 12
        imageView.isUserInteractionEnabled = true
        imageView.kf.indicatorType = .activity
        imageView.addSubview(likeButton)
        return imageView
    }()
    
    private lazy var likeButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(resource: .prFavouritesLikeEmpty), for: .normal)
        return button
    }()
    
    private lazy var nameLabel: UILabel = {
        let label = UILabel()
        label.textColor = UIColor(resource: .nftBlack)
        label.font = .bodyBold
        return label
    }()
    
    private lazy var ratingView: RatingView = RatingView()
    
    private lazy var priceLabel: UILabel = {
        let label = UILabel()
        label.textColor = UIColor(resource: .nftBlack)
        label.font = .caption1
        return label
    }()
    
    private lazy var infoStackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [
            nameLabel,
            ratingView,
            priceLabel
        ])
        stackView.axis = .vertical
        stackView.spacing = 8
        stackView.alignment = .leading
        stackView.setCustomSpacing(4, after: nameLabel)
        return stackView
    }()
    
    // MARK: - Private Properties
    
    private let likeImage = UIImage(resource: .prFavouritesLike)
    private let likeImageEmpty = UIImage(resource: .prFavouritesLikeEmpty)
    private var isLiked: Bool = false {
        didSet {
            updateLikeButton()
        }
    }
    
    // MARK: - Init
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
        setupConstraints()
        setupActions()
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        assertionFailure("init(coder:) has not been implemented")
        return nil
    }
    
    // MARK: - Overrides
    
    override func prepareForReuse() {
        super.prepareForReuse()
        nftImageView.image = nil
        isLiked = false
        likeButton.isEnabled = true
    }
    
    // MARK: - UI Methods
    
    private func setupViews() {
        contentView.backgroundColor = .clear
        contentView.addSubviews([nftImageView, infoStackView])
    }
    
    private func setupConstraints() {
        [nftImageView,
         likeButton,
         infoStackView
        ].disableAutoresizingMasks()
        
        NSLayoutConstraint.activate([
            nftImageView.widthAnchor.constraint(equalTo: nftImageView.heightAnchor),
            nftImageView.topAnchor.constraint(equalTo: contentView.topAnchor),
            nftImageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            nftImageView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor)
        ])
        
        NSLayoutConstraint.activate([
            likeButton.topAnchor.constraint(equalTo: nftImageView.topAnchor),
            likeButton.trailingAnchor.constraint(equalTo: nftImageView.trailingAnchor)
        ])
        
        NSLayoutConstraint.activate([
            infoStackView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            infoStackView.leadingAnchor.constraint(equalTo: nftImageView.trailingAnchor, constant: 12),
            infoStackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor)
        ])
    }
    
    private func setupActions() {
        likeButton.addTarget(self, action: #selector(likeButtonTapped), for: .touchUpInside)
    }
    
    // MARK: - Actions
    
    @objc private func likeButtonTapped() {
        isLiked.toggle()
        likeButton.isEnabled = false
        onLikeTap?()
    }
    
    // MARK: - Private Methods
    
    private func updateLikeButton() {
        let image = isLiked ? likeImage : likeImageEmpty
        likeButton.setImage(image, for: .normal)
    }
    
}
