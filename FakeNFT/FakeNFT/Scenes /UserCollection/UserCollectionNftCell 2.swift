import UIKit

final class UserCollectionNftCell: UICollectionViewCell, ReuseIdentifying {

    // MARK: - Callbacks
    var onLikeButtonTapped: (() -> Void)?
    var onCartTap: (() -> Void)?

    private var imageTaskId: UUID?

    // MARK: - UI

    private let nftImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.layer.cornerRadius = 12
        imageView.backgroundColor = UIColor(resource: .nftLightGray)
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()

    private let likeButton: UIButton = {
        let button = UIButton(type: .custom)
        button.setImage(UIImage(resource: .likeDefault), for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()

    private let ratingStackView: UIStackView = {
        let stack = UIStackView()
        stack.axis = .horizontal
        stack.spacing = 2
        stack.distribution = .fillEqually
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()

    private let nameLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 17, weight: .semibold)
        label.textColor = UIColor(resource: .nftBlack)
        label.numberOfLines = 1
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private let priceLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 10, weight: .medium)
        label.textColor = UIColor(resource: .nftBlack)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private let cartButton: UIButton = {
        let button = UIButton(type: .custom)
        button.setImage(UIImage(resource: .cartAdd), for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()

    // MARK: - Init

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }

    required init?(coder: NSCoder) { nil }

    // MARK: - Setup

    private func setupUI() {
        contentView.addSubview(nftImageView)
        contentView.addSubview(likeButton)
        contentView.addSubview(ratingStackView)
        contentView.addSubview(nameLabel)
        contentView.addSubview(priceLabel)
        contentView.addSubview(cartButton)

        setupRatingStars()
        setupConstraints()
        setupActions()
    }

    private func setupActions() {
        likeButton.addTarget(self, action: #selector(likeTapped), for: .touchUpInside)
        cartButton.addTarget(self, action: #selector(cartTapped), for: .touchUpInside)
    }

    @objc private func likeTapped() {
        onLikeButtonTapped?()
    }
    
    @objc private func cartTapped() {
        onCartTap?()
    }

    private func setupRatingStars() {
        for _ in 0..<5 {
            let star = UIImageView()
            star.contentMode = .scaleAspectFit
            star.image = UIImage(resource: .starNoactive)
            ratingStackView.addArrangedSubview(star)
        }
    }

    private func setupConstraints() {
        NSLayoutConstraint.activate([
            nftImageView.topAnchor.constraint(equalTo: contentView.topAnchor),
            nftImageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            nftImageView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            nftImageView.heightAnchor.constraint(equalTo: nftImageView.widthAnchor),

            likeButton.topAnchor.constraint(equalTo: nftImageView.topAnchor),
            likeButton.trailingAnchor.constraint(equalTo: nftImageView.trailingAnchor),
            likeButton.widthAnchor.constraint(equalToConstant: 40),
            likeButton.heightAnchor.constraint(equalToConstant: 40),

            ratingStackView.topAnchor.constraint(equalTo: nftImageView.bottomAnchor, constant: 8),
            ratingStackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            ratingStackView.heightAnchor.constraint(equalToConstant: 12),

            nameLabel.topAnchor.constraint(equalTo: ratingStackView.bottomAnchor, constant: 5),
            nameLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            nameLabel.trailingAnchor.constraint(equalTo: cartButton.leadingAnchor, constant: -4),
            nameLabel.heightAnchor.constraint(equalToConstant: 22),

            priceLabel.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: 2),
            priceLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            priceLabel.heightAnchor.constraint(equalToConstant: 12),

            cartButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            cartButton.centerYAnchor.constraint(equalTo: nameLabel.centerYAnchor, constant: 6),
            cartButton.widthAnchor.constraint(equalToConstant: 40),
            cartButton.heightAnchor.constraint(equalToConstant: 40),

            priceLabel.bottomAnchor.constraint(lessThanOrEqualTo: contentView.bottomAnchor, constant: -6)
        ])
    }

    // MARK: - Public

    func configure(
        imageURL: URL?,
        name: String,
        rating: Int,
        price: String,
        isLiked: Bool,
        isInCart: Bool
    ) {
        nameLabel.text = name
        priceLabel.text = price

        nftImageView.image = nil
        if let imageTaskId { ImageLoader.shared.cancel(imageTaskId) }
        if let url = imageURL {
            imageTaskId = ImageLoader.shared.load(url) { [weak self] image in
                DispatchQueue.main.async { self?.nftImageView.image = image }
            }
        }

        likeButton.setImage(isLiked ? UIImage(resource: .likePressed) : UIImage(resource: .likeDefault), for: .normal)
        cartButton.setImage(isInCart ? UIImage(resource: .cartDelete) : UIImage(resource: .cartAdd), for: .normal)

        updateRating(rating)
    }

    func setLiked(_ isLiked: Bool) {
        likeButton.setImage(isLiked ? UIImage(resource: .likePressed) : UIImage(resource: .likeDefault), for: .normal)
    }

    func setInCart(_ isInCart: Bool) {
        cartButton.setImage(isInCart ? UIImage(resource: .cartDelete) : UIImage(resource: .cartAdd), for: .normal)
    }

    private func updateRating(_ rating: Int) {
        for (i, view) in ratingStackView.arrangedSubviews.enumerated() {
            (view as? UIImageView)?.image = i < rating ? UIImage(resource: .starActive) : UIImage(resource: .starNoactive)
        }
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        if let imageTaskId { ImageLoader.shared.cancel(imageTaskId) }
        imageTaskId = nil
        nftImageView.image = nil
        onLikeButtonTapped = nil
        onCartTap = nil
    }
}

