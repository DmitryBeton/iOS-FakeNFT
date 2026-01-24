//
//  UICartTableViewCell.swift
//  FakeNFT
//
//  Created by Дмитрий Чалов on 24.01.2026.
//

import UIKit

final class CartItemViewCell: UITableViewCell, ReuseIdentifying {
    
    // MARK: - UI Elements
    private lazy var cellContentView: UIView = {
        let view = UIView()
        return view
    }()
    
    private lazy var fullInfoContainerView: UIView = {
        let view = UIView()
        return view
    }()
    
    private lazy var shortInfoContainerView: UIView = {
        let view = UIView()
        return view
    }()
    
    private lazy var nameAndRatingContainerView: UIView = {
        let view = UIView()
        return view
    }()

    private lazy var priceContainerView: UIView = {
        let view = UIView()
        return view
    }()

    private lazy var nftImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.layer.cornerRadius = Layout.Style.cornerRadius
        return imageView
    }()
    
    private lazy var nftTitleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.bodyBold
        label.textColor = UIColor(resource: .nftBlack)
        return label
    }()
    
    private lazy var ratingView: RatingView = {
        let view = RatingView()
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
        nftImageView.image = nil
        nftTitleLabel.text = nil
        ratingView.setRating(0)
        nftCurrentPriceLabel.text = nil
    }
    
    func configure(data: UICartItem) {
        nftImageView.image = data.image
        nftTitleLabel.text = data.title
        ratingView.setRating(data.rating)
        nftCurrentPriceLabel.text = data.price
    }
    
    // MARK: - UI Setup
    private func setupUI() {
        contentView.addSubview(cellContentView)
        
        cellContentView.addSubview(fullInfoContainerView)
        cellContentView.addSubview(deleteButton)

        fullInfoContainerView.addSubview(nftImageView)
        fullInfoContainerView.addSubview(shortInfoContainerView)

        shortInfoContainerView.addSubview(nameAndRatingContainerView)
        nameAndRatingContainerView.addSubview(nftTitleLabel)
        nameAndRatingContainerView.addSubview(ratingView)

        shortInfoContainerView.addSubview(priceContainerView)
        priceContainerView.addSubview(priceLabel)
        priceContainerView.addSubview(nftCurrentPriceLabel)

    }
    
    private func setupConstraints() {
        [cellContentView, fullInfoContainerView, shortInfoContainerView,
         nameAndRatingContainerView, priceContainerView, nftImageView,
         nftTitleLabel, priceLabel, nftCurrentPriceLabel, ratingView, deleteButton].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
        }
        
        NSLayoutConstraint.activate([
            // cellContentView
            cellContentView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: Layout.Spacing.horizontalInset),
            cellContentView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -Layout.Spacing.horizontalInset),
            cellContentView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: Layout.Spacing.verticalInset),
            cellContentView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -Layout.Spacing.verticalInset),

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
            nftImageView.heightAnchor.constraint(equalTo: nftImageView.widthAnchor),
            
            // shortInfoContainerView
            shortInfoContainerView.leadingAnchor.constraint(equalTo: nftImageView.trailingAnchor, constant: Layout.Spacing.imageToInfo),
            shortInfoContainerView.trailingAnchor.constraint(equalTo: fullInfoContainerView.trailingAnchor),
            shortInfoContainerView.topAnchor.constraint(equalTo: fullInfoContainerView.topAnchor, constant: Layout.Spacing.infoVertical),
            shortInfoContainerView.bottomAnchor.constraint(equalTo: fullInfoContainerView.bottomAnchor, constant: -Layout.Spacing.infoVertical),
            
            // nameAndRatingContainerView
            nameAndRatingContainerView.topAnchor.constraint(equalTo: shortInfoContainerView.topAnchor),
            nameAndRatingContainerView.leadingAnchor.constraint(equalTo: shortInfoContainerView.leadingAnchor),
            nameAndRatingContainerView.trailingAnchor.constraint(equalTo: shortInfoContainerView.trailingAnchor),
            
            // nftTitleLabel
            nftTitleLabel.topAnchor.constraint(equalTo: nameAndRatingContainerView.topAnchor),
            nftTitleLabel.leadingAnchor.constraint(equalTo: nameAndRatingContainerView.leadingAnchor),
            nftTitleLabel.trailingAnchor.constraint(lessThanOrEqualTo: nameAndRatingContainerView.trailingAnchor),
            
            // ratingView
            ratingView.topAnchor.constraint(equalTo: nftTitleLabel.bottomAnchor, constant: Layout.Spacing.nameToRating),
            ratingView.leadingAnchor.constraint(equalTo: nameAndRatingContainerView.leadingAnchor),
            ratingView.bottomAnchor.constraint(equalTo: nameAndRatingContainerView.bottomAnchor),

            // priceContainerView
            priceContainerView.topAnchor.constraint(equalTo: nameAndRatingContainerView.bottomAnchor, constant: Layout.Spacing.nameToPrice),
            priceContainerView.leadingAnchor.constraint(equalTo: shortInfoContainerView.leadingAnchor),
            priceContainerView.trailingAnchor.constraint(equalTo: shortInfoContainerView.trailingAnchor),
            priceContainerView.bottomAnchor.constraint(equalTo: shortInfoContainerView.bottomAnchor),
            
            // priceLabel
            priceLabel.topAnchor.constraint(equalTo: priceContainerView.topAnchor),
            priceLabel.leadingAnchor.constraint(equalTo: priceContainerView.leadingAnchor),
            priceLabel.trailingAnchor.constraint(lessThanOrEqualTo: priceContainerView.trailingAnchor),
            
            // nftCurrentPriceLabel
            nftCurrentPriceLabel.topAnchor.constraint(equalTo: priceLabel.bottomAnchor, constant: Layout.Spacing.priceToCurrentPrice),
            nftCurrentPriceLabel.leadingAnchor.constraint(equalTo: priceContainerView.leadingAnchor),
            nftCurrentPriceLabel.trailingAnchor.constraint(lessThanOrEqualTo: priceContainerView.trailingAnchor),
            nftCurrentPriceLabel.bottomAnchor.constraint(lessThanOrEqualTo: priceContainerView.bottomAnchor),
            
            // deleteButton
            deleteButton.trailingAnchor.constraint(equalTo: cellContentView.trailingAnchor),
            deleteButton.centerYAnchor.constraint(equalTo: cellContentView.centerYAnchor),
            deleteButton.widthAnchor.constraint(equalToConstant: Layout.Trash.size),
            deleteButton.heightAnchor.constraint(equalToConstant: Layout.Trash.size)
        ])
    }

    // MARK: - Actions
    @objc private func deleteTapped() {
        // TODO: удалить NFT из корзины
    }
}

private enum Layout {
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

    }
    
    enum Style {
        static let cornerRadius: CGFloat = 12
    }
}
