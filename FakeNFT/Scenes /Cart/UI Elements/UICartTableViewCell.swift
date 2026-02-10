//
//  UICartTableViewCell.swift
//  FakeNFT
//
//  Created by Дмитрий Чалов on 24.01.2026.
//

import UIKit
import Kingfisher

final class CartItemViewCell: UITableViewCell, ReuseIdentifying {
    // MARK: - Properties
    var onDeleteButtonTapped: (() -> Void)?
    var currentImage: UIImage? { nftImageView.image }
    private var isShowingPlaceholder = false
    private var skeletonViews: [UIView] {
        [imageSkeletonView, titleSkeletonView, ratingSkeletonView, priceSkeletonView]
    }

    // MARK: - UI Elements
    private lazy var cellContentView = UIView()

    private lazy var fullInfoContainerView = UIView()

    private lazy var shortInfoContainerView = UIView()

    private lazy var nameAndRatingContainerView = UIView()

    private lazy var priceContainerView = UIView()

    private lazy var nftImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.layer.cornerRadius = CartItemCellLayout.Style.cornerRadius
        imageView.layer.masksToBounds = true
        return imageView
    }()

    private lazy var imageSkeletonView: UIView = {
        let view = UIView()
        view.layer.cornerRadius = CartItemCellLayout.Style.cornerRadius
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
        view.layer.cornerRadius = CartItemCellLayout.Style.textCornerRadius
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
        view.layer.cornerRadius = CartItemCellLayout.Style.textCornerRadius
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
        view.layer.cornerRadius = CartItemCellLayout.Style.textCornerRadius
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
        CartItemShimmerHelper.updateFrames(in: skeletonViews)
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
        CartItemShimmerHelper.stop(in: skeletonViews)
        layoutIfNeeded()
        CartItemShimmerHelper.start(
            in: skeletonViews,
            imageView: imageSkeletonView,
            imageCornerRadius: CartItemCellLayout.Style.cornerRadius,
            textCornerRadius: CartItemCellLayout.Style.textCornerRadius
        )
    }

    private func stopShimmering() {
        CartItemShimmerHelper.stop(in: skeletonViews)
    }

    private func setupConstraints() {
        CartItemViewCellLayoutConfigurator.setupConstraints(
            with: .init(
                contentView: contentView,
                cellContentView: cellContentView,
                fullInfoContainerView: fullInfoContainerView,
                shortInfoContainerView: shortInfoContainerView,
                nameAndRatingContainerView: nameAndRatingContainerView,
                priceContainerView: priceContainerView,
                nftImageView: nftImageView,
                imageSkeletonView: imageSkeletonView,
                nftTitleLabel: nftTitleLabel,
                titleSkeletonView: titleSkeletonView,
                ratingView: ratingView,
                ratingSkeletonView: ratingSkeletonView,
                priceLabel: priceLabel,
                nftCurrentPriceLabel: nftCurrentPriceLabel,
                priceSkeletonView: priceSkeletonView,
                deleteButton: deleteButton
            )
        )
    }

    // MARK: - Actions
    @objc private func deleteTapped() {
        onDeleteButtonTapped?()
    }
}
