import UIKit

final class MyNftCell: UITableViewCell, ReuseIdentifying {
    
    // MARK: - Bindings
    
    var onLikeTap: (() -> Void)?
    
    // MARK: - Public Methods
    
    func configure(nft: MyNftUI) {
        nameLabel.text = nft.name
        nftImageView.kf.setImage(with: nft.image)
        ratingView.rating = nft.rating
        priceLabel.text = "\(nft.price) ETH"
        authorLabel.text = Localization.MyNft.fromAuthor(nft.author)
        let image = nft.isLiked ? likeImage : likeImageEmpty
        likeButton.setImage(image, for: .normal)
    }
    
    // MARK: - Private Types
    
    private enum Constants {
        enum Layout {
            static let contentStackVerticalInset: CGFloat = 16
            static let contentStackLeadingSpacing: CGFloat = 20
            static let contentStackTrailingInset: CGFloat = 16
            
            static let imageVerticalInset: CGFloat = 16
            static let imageLeadingInset: CGFloat = 16
        }
        enum Spacing {
            static let infoStackSpacing: CGFloat = 4
            static let priceStackSpacing: CGFloat = 2
            static let contentStackSpacing: CGFloat = 20
        }
        enum Radius {
            static let imageRadius: CGFloat = 12
        }
    }
    
    // MARK: - Views
    
    private lazy var nftImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.layer.masksToBounds = true
        imageView.layer.cornerRadius = Constants.Radius.imageRadius
        imageView.isUserInteractionEnabled = true
        imageView.kf.indicatorType = .activity
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
        label.text = Localization.MyNft.price
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
        stackView.spacing = Constants.Spacing.infoStackSpacing
        stackView.alignment = .leading
        return stackView
    }()
    
    private lazy var priceStackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [
            priceCaptionLabel,
            priceLabel
        ])
        stackView.axis = .vertical
        stackView.spacing = Constants.Spacing.priceStackSpacing
        stackView.alignment = .leading
        return stackView
    }()
    
    private lazy var contentStackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [
            infoStackView,
            priceStackView
        ])
        stackView.axis = .horizontal
        stackView.spacing = Constants.Spacing.contentStackSpacing
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
        setupActions()
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        assertionFailure("init(coder:) has not been implemented")
        return nil
    }
    
    // MARK: - UI Methods
    
    private func setupViews() {
        selectionStyle = .none
        contentView.backgroundColor = UIColor(resource: .nftWhite)
        contentView.addSubviews([nftImageView, contentStackView])
    }
    
    private func setupConstraints() {
        [nftImageView, contentStackView, likeButton].disableAutoresizingMasks()
        
        NSLayoutConstraint.activate([
            contentStackView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: Constants.Layout.contentStackVerticalInset),
            contentStackView.leadingAnchor.constraint(equalTo: nftImageView.trailingAnchor,constant: Constants.Layout.contentStackLeadingSpacing),
            contentStackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -Constants.Layout.contentStackTrailingInset),
            contentStackView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -Constants.Layout.contentStackVerticalInset)
        ])
        
        NSLayoutConstraint.activate([
            nftImageView.widthAnchor.constraint(equalTo: nftImageView.heightAnchor),
            nftImageView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: Constants.Layout.imageVerticalInset),
            nftImageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: Constants.Layout.imageLeadingInset),
            nftImageView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -Constants.Layout.imageVerticalInset)
        ])
        
        NSLayoutConstraint.activate([
            likeButton.topAnchor.constraint(equalTo: nftImageView.topAnchor),
            likeButton.trailingAnchor.constraint(equalTo: nftImageView.trailingAnchor)
        ])
    }
    
    private func setupActions() {
        likeButton.addTarget(self, action: #selector(likeButtonTapped), for: .touchUpInside)
    }
    
    // MARK: - Actions
    
    @objc private func likeButtonTapped() {
        onLikeTap?()
    }
    
}
