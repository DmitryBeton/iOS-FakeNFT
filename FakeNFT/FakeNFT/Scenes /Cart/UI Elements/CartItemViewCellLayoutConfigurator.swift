import UIKit

enum CartItemCellLayout {
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

enum CartItemViewCellLayoutConfigurator {
    struct Views {
        let contentView: UIView
        let cellContentView: UIView
        let fullInfoContainerView: UIView
        let shortInfoContainerView: UIView
        let nameAndRatingContainerView: UIView
        let priceContainerView: UIView
        let nftImageView: UIImageView
        let imageSkeletonView: UIView
        let nftTitleLabel: UILabel
        let titleSkeletonView: UIView
        let ratingView: UIView
        let ratingSkeletonView: UIView
        let priceLabel: UILabel
        let nftCurrentPriceLabel: UILabel
        let priceSkeletonView: UIView
        let deleteButton: UIButton
    }

    static func setupConstraints(with views: Views) {
        let contentView = views.contentView
        let cellContentView = views.cellContentView
        let fullInfoContainerView = views.fullInfoContainerView
        let shortInfoContainerView = views.shortInfoContainerView
        let nameAndRatingContainerView = views.nameAndRatingContainerView
        let priceContainerView = views.priceContainerView
        let nftImageView = views.nftImageView
        let imageSkeletonView = views.imageSkeletonView
        let nftTitleLabel = views.nftTitleLabel
        let titleSkeletonView = views.titleSkeletonView
        let ratingView = views.ratingView
        let ratingSkeletonView = views.ratingSkeletonView
        let priceLabel = views.priceLabel
        let nftCurrentPriceLabel = views.nftCurrentPriceLabel
        let priceSkeletonView = views.priceSkeletonView
        let deleteButton = views.deleteButton

        [cellContentView, fullInfoContainerView, shortInfoContainerView,
         nameAndRatingContainerView, priceContainerView, nftImageView,
         imageSkeletonView, nftTitleLabel, titleSkeletonView, priceLabel,
         nftCurrentPriceLabel, priceSkeletonView, ratingView, ratingSkeletonView, deleteButton].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
        }

        let cellBottom = cellContentView.bottomAnchor.constraint(lessThanOrEqualTo: contentView.bottomAnchor, constant: -CartItemCellLayout.Spacing.verticalInset)
        cellBottom.priority = .defaultHigh

        let imageAspect = nftImageView.heightAnchor.constraint(equalTo: nftImageView.widthAnchor)
        imageAspect.priority = .defaultHigh

        let shortInfoBottom = shortInfoContainerView.bottomAnchor.constraint(lessThanOrEqualTo: fullInfoContainerView.bottomAnchor, constant: -CartItemCellLayout.Spacing.infoVertical)
        shortInfoBottom.priority = .defaultHigh

        let titleSkeletonHeight = titleSkeletonView.heightAnchor.constraint(equalToConstant: CartItemCellLayout.Size.titleSkeletonHeight)
        titleSkeletonHeight.priority = .defaultHigh

        let ratingSkeletonHeight = ratingSkeletonView.heightAnchor.constraint(equalToConstant: CartItemCellLayout.Size.ratingSkeletonHeight)
        ratingSkeletonHeight.priority = .defaultHigh

        let ratingTop = ratingView.topAnchor.constraint(equalTo: nftTitleLabel.bottomAnchor, constant: CartItemCellLayout.Spacing.nameToRating)
        ratingTop.priority = .defaultHigh

        let ratingSkeletonTop = ratingSkeletonView.topAnchor.constraint(equalTo: titleSkeletonView.bottomAnchor, constant: CartItemCellLayout.Spacing.nameToRating)
        ratingSkeletonTop.priority = .defaultHigh

        let priceContainerTop = priceContainerView.topAnchor.constraint(equalTo: nameAndRatingContainerView.bottomAnchor, constant: CartItemCellLayout.Spacing.nameToPrice)
        priceContainerTop.priority = .defaultHigh

        let priceBottom = priceContainerView.bottomAnchor.constraint(lessThanOrEqualTo: shortInfoContainerView.bottomAnchor)
        priceBottom.priority = .defaultHigh

        let priceSkeletonHeight = priceSkeletonView.heightAnchor.constraint(equalToConstant: CartItemCellLayout.Size.priceSkeletonHeight)
        priceSkeletonHeight.priority = .defaultHigh

        NSLayoutConstraint.activate([
            cellContentView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: CartItemCellLayout.Spacing.horizontalInset),
            cellContentView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -CartItemCellLayout.Spacing.horizontalInset),
            cellContentView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: CartItemCellLayout.Spacing.verticalInset),
            cellBottom,

            fullInfoContainerView.leadingAnchor.constraint(equalTo: cellContentView.leadingAnchor),
            fullInfoContainerView.topAnchor.constraint(equalTo: cellContentView.topAnchor),
            fullInfoContainerView.bottomAnchor.constraint(lessThanOrEqualTo: cellContentView.bottomAnchor),
            fullInfoContainerView.trailingAnchor.constraint(equalTo: deleteButton.leadingAnchor, constant: -CartItemCellLayout.Spacing.imageToInfo),

            nftImageView.leadingAnchor.constraint(equalTo: fullInfoContainerView.leadingAnchor),
            nftImageView.topAnchor.constraint(equalTo: fullInfoContainerView.topAnchor),
            nftImageView.bottomAnchor.constraint(lessThanOrEqualTo: fullInfoContainerView.bottomAnchor),
            nftImageView.widthAnchor.constraint(equalToConstant: CartItemCellLayout.Image.size),
            imageAspect,

            imageSkeletonView.leadingAnchor.constraint(equalTo: nftImageView.leadingAnchor),
            imageSkeletonView.trailingAnchor.constraint(equalTo: nftImageView.trailingAnchor),
            imageSkeletonView.topAnchor.constraint(equalTo: nftImageView.topAnchor),
            imageSkeletonView.bottomAnchor.constraint(equalTo: nftImageView.bottomAnchor),

            shortInfoContainerView.leadingAnchor.constraint(equalTo: nftImageView.trailingAnchor, constant: CartItemCellLayout.Spacing.imageToInfo),
            shortInfoContainerView.trailingAnchor.constraint(equalTo: fullInfoContainerView.trailingAnchor),
            shortInfoContainerView.topAnchor.constraint(equalTo: fullInfoContainerView.topAnchor, constant: CartItemCellLayout.Spacing.infoVertical),
            shortInfoBottom,

            nameAndRatingContainerView.topAnchor.constraint(equalTo: shortInfoContainerView.topAnchor),
            nameAndRatingContainerView.leadingAnchor.constraint(equalTo: shortInfoContainerView.leadingAnchor),
            nameAndRatingContainerView.trailingAnchor.constraint(equalTo: shortInfoContainerView.trailingAnchor),

            nftTitleLabel.topAnchor.constraint(equalTo: nameAndRatingContainerView.topAnchor),
            nftTitleLabel.leadingAnchor.constraint(equalTo: nameAndRatingContainerView.leadingAnchor),
            nftTitleLabel.trailingAnchor.constraint(lessThanOrEqualTo: nameAndRatingContainerView.trailingAnchor),

            titleSkeletonView.topAnchor.constraint(equalTo: nameAndRatingContainerView.topAnchor),
            titleSkeletonView.leadingAnchor.constraint(equalTo: nameAndRatingContainerView.leadingAnchor),
            titleSkeletonHeight,
            titleSkeletonView.widthAnchor.constraint(equalToConstant: CartItemCellLayout.Size.titleSkeletonWidth),

            ratingTop,
            ratingView.leadingAnchor.constraint(equalTo: nameAndRatingContainerView.leadingAnchor),
            ratingView.bottomAnchor.constraint(equalTo: nameAndRatingContainerView.bottomAnchor),

            ratingSkeletonTop,
            ratingSkeletonView.leadingAnchor.constraint(equalTo: nameAndRatingContainerView.leadingAnchor),
            ratingSkeletonHeight,
            ratingSkeletonView.widthAnchor.constraint(equalToConstant: CartItemCellLayout.Size.ratingSkeletonWidth),
            ratingSkeletonView.bottomAnchor.constraint(equalTo: nameAndRatingContainerView.bottomAnchor),

            priceContainerTop,
            priceContainerView.leadingAnchor.constraint(equalTo: shortInfoContainerView.leadingAnchor),
            priceContainerView.trailingAnchor.constraint(equalTo: shortInfoContainerView.trailingAnchor),
            priceBottom,

            priceLabel.topAnchor.constraint(equalTo: priceContainerView.topAnchor),
            priceLabel.leadingAnchor.constraint(equalTo: priceContainerView.leadingAnchor),
            priceLabel.trailingAnchor.constraint(lessThanOrEqualTo: priceContainerView.trailingAnchor),

            nftCurrentPriceLabel.topAnchor.constraint(equalTo: priceLabel.bottomAnchor, constant: CartItemCellLayout.Spacing.priceToCurrentPrice),
            nftCurrentPriceLabel.leadingAnchor.constraint(equalTo: priceContainerView.leadingAnchor),
            nftCurrentPriceLabel.trailingAnchor.constraint(lessThanOrEqualTo: priceContainerView.trailingAnchor),
            nftCurrentPriceLabel.bottomAnchor.constraint(lessThanOrEqualTo: priceContainerView.bottomAnchor),

            priceSkeletonView.topAnchor.constraint(equalTo: priceContainerView.topAnchor, constant: CartItemCellLayout.Spacing.priceSkeletonTopInset),
            priceSkeletonView.leadingAnchor.constraint(equalTo: priceContainerView.leadingAnchor),
            priceSkeletonHeight,
            priceSkeletonView.widthAnchor.constraint(equalToConstant: CartItemCellLayout.Size.priceSkeletonWidth),

            deleteButton.trailingAnchor.constraint(equalTo: cellContentView.trailingAnchor),
            deleteButton.centerYAnchor.constraint(equalTo: cellContentView.centerYAnchor),
            deleteButton.widthAnchor.constraint(equalToConstant: CartItemCellLayout.Trash.size),
            deleteButton.heightAnchor.constraint(equalToConstant: CartItemCellLayout.Trash.size)
        ])
    }
}
