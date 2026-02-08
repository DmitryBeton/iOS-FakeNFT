//
//  UICartTableViewCell.swift
//  FakeNFT
//
//  Created by Дмитрий Чалов on 24.01.2026.
//

import UIKit
import Kingfisher

final class CartItemViewCell: UITableViewCell, ReuseIdentifying {
    private static let shimmerLayerName = "cart.shimmer.layer"
    private static let shimmerAnimationKey = "cart.shimmer.animation"

    // MARK: - Properties
    var onDeleteButtonTapped: (() -> Void)?
    var currentImage: UIImage? { nftImageView.image }
    private var isShowingPlaceholder = false

    // MARK: - UI Elements
    private lazy var cellContentView = UIView()

    private lazy var fullInfoContainerView = UIView()

    private lazy var shortInfoContainerView = UIView()

    private lazy var nameAndRatingContainerView = UIView()

    private lazy var priceContainerView = UIView()

    private lazy var nftImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.layer.cornerRadius = Layout.Style.cornerRadius
        imageView.layer.masksToBounds = true
        return imageView
    }()

    private lazy var imageSkeletonView: UIView = {
        let view = UIView()
        view.layer.cornerRadius = Layout.Style.cornerRadius
        view.layer.masksToBounds = true
        view.isHidden = true
        return view
    }()

    private lazy var nftTitleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.bodyBold
        label.textColor = UIColor(resource: .nftBlack)
        return label
    }()

    private lazy var titleSkeletonView: UIView = {
        let view = UIView()
        view.layer.cornerRadius = Layout.Style.textCornerRadius
        view.layer.masksToBounds = true
        view.isHidden = true
        return view
    }()

    private lazy var ratingView: RatingView = {
        let view = RatingView()
        return view
    }()

    private lazy var ratingSkeletonView: UIView = {
        let view = UIView()
        view.layer.cornerRadius = Layout.Style.textCornerRadius
        view.layer.masksToBounds = true
        view.isHidden = true
        return view
    }()

    private let priceLabel: UILabel = {
        let label = UILabel()
        label.text = Localization.Cart.price.localized
        label.font = UIFont.caption2
        label.textColor = UIColor(resource: .nftBlack)
        return label
    }()

    private lazy var nftCurrentPriceLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.bodyBold
        label.textColor = UIColor(resource: .nftBlack)
        return label
    }()

    private lazy var priceSkeletonView: UIView = {
        let view = UIView()
        view.layer.cornerRadius = Layout.Style.textCornerRadius
        view.layer.masksToBounds = true
        view.isHidden = true
        return view
    }()

    private lazy var deleteButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(resource: .deleteItemIcon), for: .normal)
        button.tintColor = UIColor(resource: .nftBlack)
        button.addTarget(self, action: #selector(deleteTapped), for: .touchUpInside)
        return button
    }()

    // MARK: - Initializers
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        selectionStyle = .none
        backgroundColor = .clear
        setupUI()
        setupConstraints()
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        nil
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        nftImageView.kf.cancelDownloadTask()
        stopShimmering()
        isShowingPlaceholder = false
        nftImageView.image = nil
        nftTitleLabel.text = nil
        nftTitleLabel.isHidden = false
        priceLabel.isHidden = false
        ratingView.isHidden = false
        ratingView.setRating(0)
        nftCurrentPriceLabel.text = nil
        nftCurrentPriceLabel.isHidden = false
        nftImageView.isHidden = false
        imageSkeletonView.isHidden = true
        titleSkeletonView.isHidden = true
        ratingSkeletonView.isHidden = true
        priceSkeletonView.isHidden = true
    }

    func configure(data: UICartItem) {
        if data.isPlaceholder {
            configurePlaceholder()
        } else {
            configureContent(data: data)
        }
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        guard isShowingPlaceholder else { return }
        updateShimmerFrames()
    }

    func setCellImage(with url: URL) {
        nftImageView.kf.indicatorType = .activity
        nftImageView.kf.setImage(
            with: url,
            placeholder: nil,
            options: [
                .transition(.fade(0.2)),
                .cacheOriginalImage
            ]
        ) { [weak self] result in
            switch result {
            case .success:
                self?.setNeedsLayout()
            case .failure:
                break
            }
        }
    }

    // MARK: - UI Setup
    private func setupUI() {
        contentView.addSubview(cellContentView)

        cellContentView.addSubview(fullInfoContainerView)
        cellContentView.addSubview(deleteButton)

        fullInfoContainerView.addSubview(nftImageView)
        fullInfoContainerView.addSubview(imageSkeletonView)
        fullInfoContainerView.addSubview(shortInfoContainerView)

        shortInfoContainerView.addSubview(nameAndRatingContainerView)
        nameAndRatingContainerView.addSubview(nftTitleLabel)
        nameAndRatingContainerView.addSubview(titleSkeletonView)
        nameAndRatingContainerView.addSubview(ratingView)
        nameAndRatingContainerView.addSubview(ratingSkeletonView)

        shortInfoContainerView.addSubview(priceContainerView)
        priceContainerView.addSubview(priceLabel)
        priceContainerView.addSubview(nftCurrentPriceLabel)
        priceContainerView.addSubview(priceSkeletonView)

    }

    func configurePlaceholder() {
        isShowingPlaceholder = true
        nftImageView.image = nil

        nftImageView.isHidden = true
        nftTitleLabel.isHidden = true
        ratingView.isHidden = true
        priceLabel.isHidden = true
        nftCurrentPriceLabel.isHidden = true

        imageSkeletonView.isHidden = false
        titleSkeletonView.isHidden = false
        ratingSkeletonView.isHidden = false
        priceSkeletonView.isHidden = false
        startShimmering()
    }

    func configureContent(data: UICartItem) {
        isShowingPlaceholder = false
        stopShimmering()

        imageSkeletonView.isHidden = true
        titleSkeletonView.isHidden = true
        ratingSkeletonView.isHidden = true
        priceSkeletonView.isHidden = true

        nftImageView.isHidden = false
        nftTitleLabel.isHidden = false
        nftTitleLabel.text = data.title
        ratingView.isHidden = false
        ratingView.setRating(data.rating)
        priceLabel.isHidden = false
        nftCurrentPriceLabel.isHidden = false
        nftCurrentPriceLabel.text = data.price
    }

    private func startShimmering() {
        stopShimmering()
        layoutIfNeeded()
        addShimmer(to: imageSkeletonView, cornerRadius: Layout.Style.cornerRadius)
        addShimmer(to: titleSkeletonView, cornerRadius: Layout.Style.textCornerRadius)
        addShimmer(to: ratingSkeletonView, cornerRadius: Layout.Style.textCornerRadius)
        addShimmer(to: priceSkeletonView, cornerRadius: Layout.Style.textCornerRadius)
    }

    private func stopShimmering() {
        [imageSkeletonView, titleSkeletonView, ratingSkeletonView, priceSkeletonView].forEach { view in
            view.layer.sublayers?
                .filter { $0.name == Self.shimmerLayerName }
                .forEach { $0.removeFromSuperlayer() }
        }
    }

    private func updateShimmerFrames() {
        [imageSkeletonView, titleSkeletonView, ratingSkeletonView, priceSkeletonView].forEach { view in
            view.layer.sublayers?
                .filter { $0.name == Self.shimmerLayerName }
                .forEach { $0.frame = view.bounds }
        }
    }

    private func addShimmer(to view: UIView, cornerRadius: CGFloat) {
        guard !view.bounds.isEmpty else { return }

        let baseColor = UIColor(resource: .nftLightGray).cgColor
        let highlightColor = UIColor(resource: .nftWhite).withAlphaComponent(0.7).cgColor

        let gradient = CAGradientLayer()
        gradient.name = Self.shimmerLayerName
        gradient.frame = view.bounds
        gradient.cornerRadius = cornerRadius
        gradient.colors = [baseColor, highlightColor, baseColor]
        gradient.locations = [0.0, 0.5, 1.0]
        gradient.startPoint = CGPoint(x: 0, y: 0.5)
        gradient.endPoint = CGPoint(x: 1, y: 0.5)

        let animation = CABasicAnimation(keyPath: "locations")
        animation.fromValue = [-1.0, -0.5, 0.0]
        animation.toValue = [1.0, 1.5, 2.0]
        animation.duration = 1.1
        animation.repeatCount = .infinity
        gradient.add(animation, forKey: Self.shimmerAnimationKey)

        view.layer.addSublayer(gradient)
    }

    private func setupConstraints() {
        [cellContentView, fullInfoContainerView, shortInfoContainerView,
         nameAndRatingContainerView, priceContainerView, nftImageView,
         imageSkeletonView, nftTitleLabel, titleSkeletonView, priceLabel,
         nftCurrentPriceLabel, priceSkeletonView, ratingView, ratingSkeletonView, deleteButton].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
        }

        let cellBottom = cellContentView.bottomAnchor.constraint(lessThanOrEqualTo: contentView.bottomAnchor, constant: -Layout.Spacing.verticalInset)
        cellBottom.priority = .defaultHigh

        let imageAspect = nftImageView.heightAnchor.constraint(equalTo: nftImageView.widthAnchor)
        imageAspect.priority = .defaultHigh

        let shortInfoBottom = shortInfoContainerView.bottomAnchor.constraint(lessThanOrEqualTo: fullInfoContainerView.bottomAnchor, constant: -Layout.Spacing.infoVertical)
        shortInfoBottom.priority = .defaultHigh

        let titleSkeletonHeight = titleSkeletonView.heightAnchor.constraint(equalToConstant: Layout.Size.titleSkeletonHeight)
        titleSkeletonHeight.priority = .defaultHigh

        let ratingSkeletonHeight = ratingSkeletonView.heightAnchor.constraint(equalToConstant: Layout.Size.ratingSkeletonHeight)
        ratingSkeletonHeight.priority = .defaultHigh

        let ratingTop = ratingView.topAnchor.constraint(equalTo: nftTitleLabel.bottomAnchor, constant: Layout.Spacing.nameToRating)
        ratingTop.priority = .defaultHigh

        let ratingSkeletonTop = ratingSkeletonView.topAnchor.constraint(equalTo: titleSkeletonView.bottomAnchor, constant: Layout.Spacing.nameToRating)
        ratingSkeletonTop.priority = .defaultHigh

        let priceContainerTop = priceContainerView.topAnchor.constraint(equalTo: nameAndRatingContainerView.bottomAnchor, constant: Layout.Spacing.nameToPrice)
        priceContainerTop.priority = .defaultHigh

        let priceBottom = priceContainerView.bottomAnchor.constraint(lessThanOrEqualTo: shortInfoContainerView.bottomAnchor)
        priceBottom.priority = .defaultHigh

        let priceSkeletonHeight = priceSkeletonView.heightAnchor.constraint(equalToConstant: Layout.Size.priceSkeletonHeight)
        priceSkeletonHeight.priority = .defaultHigh

        NSLayoutConstraint.activate([
            // cellContentView
            cellContentView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: Layout.Spacing.horizontalInset),
            cellContentView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -Layout.Spacing.horizontalInset),
            cellContentView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: Layout.Spacing.verticalInset),
            cellBottom,

            // fullInfoContainerView
            fullInfoContainerView.leadingAnchor.constraint(equalTo: cellContentView.leadingAnchor),
            fullInfoContainerView.topAnchor.constraint(equalTo: cellContentView.topAnchor),
            fullInfoContainerView.bottomAnchor.constraint(lessThanOrEqualTo: cellContentView.bottomAnchor),
            fullInfoContainerView.trailingAnchor.constraint(equalTo: deleteButton.leadingAnchor, constant: -Layout.Spacing.imageToInfo),

            // nftImageView
            nftImageView.leadingAnchor.constraint(equalTo: fullInfoContainerView.leadingAnchor),
            nftImageView.topAnchor.constraint(equalTo: fullInfoContainerView.topAnchor),
            nftImageView.bottomAnchor.constraint(lessThanOrEqualTo: fullInfoContainerView.bottomAnchor),
            nftImageView.widthAnchor.constraint(equalToConstant: Layout.Image.size),
            imageAspect,

            // imageSkeletonView
            imageSkeletonView.leadingAnchor.constraint(equalTo: nftImageView.leadingAnchor),
            imageSkeletonView.trailingAnchor.constraint(equalTo: nftImageView.trailingAnchor),
            imageSkeletonView.topAnchor.constraint(equalTo: nftImageView.topAnchor),
            imageSkeletonView.bottomAnchor.constraint(equalTo: nftImageView.bottomAnchor),

            // shortInfoContainerView
            shortInfoContainerView.leadingAnchor.constraint(equalTo: nftImageView.trailingAnchor, constant: Layout.Spacing.imageToInfo),
            shortInfoContainerView.trailingAnchor.constraint(equalTo: fullInfoContainerView.trailingAnchor),
            shortInfoContainerView.topAnchor.constraint(equalTo: fullInfoContainerView.topAnchor, constant: Layout.Spacing.infoVertical),
            shortInfoBottom,

            // nameAndRatingContainerView
            nameAndRatingContainerView.topAnchor.constraint(equalTo: shortInfoContainerView.topAnchor),
            nameAndRatingContainerView.leadingAnchor.constraint(equalTo: shortInfoContainerView.leadingAnchor),
            nameAndRatingContainerView.trailingAnchor.constraint(equalTo: shortInfoContainerView.trailingAnchor),

            // nftTitleLabel
            nftTitleLabel.topAnchor.constraint(equalTo: nameAndRatingContainerView.topAnchor),
            nftTitleLabel.leadingAnchor.constraint(equalTo: nameAndRatingContainerView.leadingAnchor),
            nftTitleLabel.trailingAnchor.constraint(lessThanOrEqualTo: nameAndRatingContainerView.trailingAnchor),

            // titleSkeletonView
            titleSkeletonView.topAnchor.constraint(equalTo: nameAndRatingContainerView.topAnchor),
            titleSkeletonView.leadingAnchor.constraint(equalTo: nameAndRatingContainerView.leadingAnchor),
            titleSkeletonHeight,
            titleSkeletonView.widthAnchor.constraint(equalToConstant: Layout.Size.titleSkeletonWidth),

            // ratingView
            ratingTop,
            ratingView.leadingAnchor.constraint(equalTo: nameAndRatingContainerView.leadingAnchor),
            ratingView.bottomAnchor.constraint(equalTo: nameAndRatingContainerView.bottomAnchor),

            // ratingSkeletonView
            ratingSkeletonTop,
            ratingSkeletonView.leadingAnchor.constraint(equalTo: nameAndRatingContainerView.leadingAnchor),
            ratingSkeletonHeight,
            ratingSkeletonView.widthAnchor.constraint(equalToConstant: Layout.Size.ratingSkeletonWidth),
            ratingSkeletonView.bottomAnchor.constraint(equalTo: nameAndRatingContainerView.bottomAnchor),

            // priceContainerView
            priceContainerTop,
            priceContainerView.leadingAnchor.constraint(equalTo: shortInfoContainerView.leadingAnchor),
            priceContainerView.trailingAnchor.constraint(equalTo: shortInfoContainerView.trailingAnchor),
            priceBottom,

            // priceLabel
            priceLabel.topAnchor.constraint(equalTo: priceContainerView.topAnchor),
            priceLabel.leadingAnchor.constraint(equalTo: priceContainerView.leadingAnchor),
            priceLabel.trailingAnchor.constraint(lessThanOrEqualTo: priceContainerView.trailingAnchor),

            // nftCurrentPriceLabel
            nftCurrentPriceLabel.topAnchor.constraint(equalTo: priceLabel.bottomAnchor, constant: Layout.Spacing.priceToCurrentPrice),
            nftCurrentPriceLabel.leadingAnchor.constraint(equalTo: priceContainerView.leadingAnchor),
            nftCurrentPriceLabel.trailingAnchor.constraint(lessThanOrEqualTo: priceContainerView.trailingAnchor),
            nftCurrentPriceLabel.bottomAnchor.constraint(lessThanOrEqualTo: priceContainerView.bottomAnchor),

            // priceSkeletonView
            priceSkeletonView.topAnchor.constraint(equalTo: priceContainerView.topAnchor, constant: Layout.Spacing.priceSkeletonTopInset),
            priceSkeletonView.leadingAnchor.constraint(equalTo: priceContainerView.leadingAnchor),
            priceSkeletonHeight,
            priceSkeletonView.widthAnchor.constraint(equalToConstant: Layout.Size.priceSkeletonWidth),

            // deleteButton
            deleteButton.trailingAnchor.constraint(equalTo: cellContentView.trailingAnchor),
            deleteButton.centerYAnchor.constraint(equalTo: cellContentView.centerYAnchor),
            deleteButton.widthAnchor.constraint(equalToConstant: Layout.Trash.size),
            deleteButton.heightAnchor.constraint(equalToConstant: Layout.Trash.size)
        ])
    }

    // MARK: - Actions
    @objc private func deleteTapped() {
        onDeleteButtonTapped?()
    }
}

private enum Layout {
    enum Size {
        static let titleSkeletonWidth: CGFloat = 130
        static let titleSkeletonHeight: CGFloat = 20
        static let ratingSkeletonWidth: CGFloat = 74
        static let ratingSkeletonHeight: CGFloat = 12
        static let priceSkeletonWidth: CGFloat = 84
        static let priceSkeletonHeight: CGFloat = 20
    }

    enum Trash {
        static let size: CGFloat = 40
    }

    enum Image {
        static let size: CGFloat = 108
    }

    enum Spacing {
        static let horizontalInset: CGFloat = 16
        static let verticalInset: CGFloat = 16
        static let imageToInfo: CGFloat = 20
        static let infoVertical: CGFloat = 8
        static let nameToPrice: CGFloat = 12
        static let nameToRating: CGFloat = 4
        static let priceToCurrentPrice: CGFloat = 2
        static let priceSkeletonTopInset: CGFloat = 2

    }

    enum Style {
        static let cornerRadius: CGFloat = 12
        static let textCornerRadius: CGFloat = 6
    }
}
