import UIKit

final class MyNFTCell: UITableViewCell, ReuseIdentifying {
    
    // MARK: - Public Methods
    
    func configure(nft: NftUI) {
        nameLabel.text = nft.name
        nftImageView.kf.setImage(with: nft.image)
        ratingView.rating = nft.rating
        priceLabel.text = "\(nft.price) ETH"
        authorLabel.text = Localization.MyNFT.fromAuthor(nft.author)
        let image: UIImage = nft.isLiked ? likeImage : likeImageEmpty
        likeButton.setImage(image, for: .normal)
    }
    
    // MARK: - Views
    
    private lazy var nftImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.layer.masksToBounds = true
        imageView.layer.cornerRadius = 12
        imageView.addSubview(likeButton)
        return imageView
    }()
    
    private lazy var likeButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(resource: .prLikeEmpty), for: .normal)
        return button
    }()
    
    private lazy var nameLabel: UILabel = {
        let label = UILabel()
        label.textColor = UIColor(resource: .nftBlack)
        label.font = .bodyBold
        return label
    }()
    
    private lazy var ratingView: RatingView = RatingView()
    
    private lazy var authorLabel: UILabel = {
        let label = UILabel()
        label.font = .caption2
        label.textColor = UIColor(resource: .nftBlack)
        return label
    }()
    
    private lazy var priceCaptionLabel: UILabel = {
        let label = UILabel()
        label.font = .caption2
        label.textColor = UIColor(resource: .nftBlack)
        label.text = Localization.MyNFT.price
        return label
    }()
    
    private lazy var priceLabel: UILabel = {
        let label = UILabel()
        label.textColor = UIColor(resource: .nftBlack)
        label.font = .bodyBold
        return label
    }()
    
    private lazy var infoStackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [
            nameLabel,
            ratingView,
            authorLabel
        ])
        stackView.axis = .vertical
        stackView.spacing = 4
        stackView.alignment = .leading
        return stackView
    }()
    
    private lazy var priceStackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [
            priceCaptionLabel,
            priceLabel
        ])
        stackView.axis = .vertical
        stackView.spacing = 2
        stackView.alignment = .leading
        return stackView
    }()
    
    private lazy var contentStackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [
            nftImageView,
            infoStackView,
            priceStackView
        ])
        stackView.axis = .horizontal
        stackView.spacing = 20
        stackView.alignment = .center
        stackView.distribution = .fillEqually
        return stackView
    }()
    
    // MARK: - Private Properties
    
    private let likeImage = UIImage(resource: .prLike)
    private let likeImageEmpty = UIImage(resource: .prLikeEmpty)
    
    // MARK: - Init
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupViews()
        setupConstraints()
    }
    
    required init?(coder: NSCoder) {
        assertionFailure("init(coder:) has not been implemented")
        return nil
    }
    
    // MARK: - UI Methods
    
    private func setupViews() {
        selectionStyle = .none
        contentView.backgroundColor = .clear
        contentView.addSubview(contentStackView)
    }
    
    private func setupConstraints() {
        [contentStackView, likeButton].disableAutoresizingMasks()
        
        NSLayoutConstraint.activate([
            contentStackView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 16),
            contentStackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor,constant: 16),
            contentStackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            contentStackView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -16)
        ])
        
        NSLayoutConstraint.activate([
            nftImageView.heightAnchor.constraint(equalToConstant: 108),
            nftImageView.widthAnchor.constraint(equalToConstant: 108)
        ])
        
        NSLayoutConstraint.activate([
            likeButton.topAnchor.constraint(equalTo: nftImageView.topAnchor),
            likeButton.trailingAnchor.constraint(equalTo: nftImageView.trailingAnchor)
        ])
    }
    
}
