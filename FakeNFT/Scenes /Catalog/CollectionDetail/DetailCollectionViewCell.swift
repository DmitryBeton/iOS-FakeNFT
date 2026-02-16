import UIKit
import Kingfisher

final class DetailCollectionViewCell: UICollectionViewCell {

    // MARK: - Properties

    static let reuseIdentifier = "DetailCollectionViewCell"

    var onLikeButtonTapped: (() -> Void)?
    var onCartButtonTapped: (() -> Void)?

    private var isLiked: Bool = false

    // MARK: - UI Elements

    private let nftImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.layer.cornerRadius = 12
        imageView.backgroundColor = .systemGray6
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
        label.font = .systemFont(ofSize: 17, weight: .bold)
        label.textColor = UIColor(resource: .nftBlack)
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

    // MARK: - Initialization

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

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
        likeButton.addTarget(self, action: #selector(likeButtonTapped), for: .touchUpInside)
        cartButton.addTarget(self, action: #selector(cartButtonTapped), for: .touchUpInside)
    }

    @objc private func likeButtonTapped() {
        onLikeButtonTapped?()
    }

    @objc private func cartButtonTapped() {
        onCartButtonTapped?()
    }

    private func setupRatingStars() {
        for _ in 0..<5 {
            let starImageView = UIImageView()
            starImageView.contentMode = .scaleAspectFit
            starImageView.image = UIImage(resource: .starNoactive)
            ratingStackView.addArrangedSubview(starImageView)
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

            priceLabel.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: 4),
            priceLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),

            cartButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            cartButton.centerYAnchor.constraint(equalTo: nameLabel.centerYAnchor, constant: 6),
            cartButton.widthAnchor.constraint(equalToConstant: 40),
            cartButton.heightAnchor.constraint(equalToConstant: 40)
        ])
    }

    // MARK: - Public Methods

    func configure(
        imageURL: URL?,
        name: String,
        rating: Int,
        price: String,
        isLiked: Bool,
        isInCart: Bool
    ) {
        nftImageView.kf.setImage(with: imageURL)
        nameLabel.text = name
        priceLabel.text = price

        let likeImage = isLiked ? UIImage(resource: .likePressed) : UIImage(resource: .likeDefault)
        likeButton.setImage(likeImage, for: .normal)

        let cartImage = isInCart ? UIImage(resource: .cartDelete) : UIImage(resource: .cartAdd)
        cartButton.setImage(cartImage, for: .normal)

        updateRating(rating)
    }

    func setLiked(_ isLiked: Bool) {
        self.isLiked = isLiked
        let likeImage = isLiked ? UIImage(resource: .likePressed) : UIImage(resource: .likeDefault)
        likeButton.setImage(likeImage, for: .normal)
    }

    func setInCart(_ isInCart: Bool) {
        let cartImage = isInCart ? UIImage(resource: .cartDelete) : UIImage(resource: .cartAdd)
        cartButton.setImage(cartImage, for: .normal)
    }

    private func updateRating(_ rating: Int) {
        for (index, view) in ratingStackView.arrangedSubviews.enumerated() {
            guard let starView = view as? UIImageView else { continue }
            starView.image = index < rating
                ? UIImage(resource: .starActive)
                : UIImage(resource: .starNoactive)
        }
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        nftImageView.kf.cancelDownloadTask()
        nftImageView.image = nil
        onLikeButtonTapped = nil
        onCartButtonTapped = nil
    }
}
