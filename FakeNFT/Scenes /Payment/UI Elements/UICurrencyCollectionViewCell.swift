//
//  UICurrencyCollectionViewCell.swift
//  FakeNFT
//
//  Created by Дмитрий Чалов on 31.01.2026.
//

import UIKit

final class UICurrencyCollectionViewCell: UICollectionViewCell, ReuseIdentifying {
    // MARK: - UI Elements
    private let paddingView = UIView()
    
    private let paddingImageView: UIView = {
        let view = UIView()
        view.layer.cornerRadius = Constants.Layout.imageContainerCornerRadius
        view.backgroundColor = UIColor(resource: .nftBlackUni)
        return view
    }()
    
    private let currencyImageView: UIImageView = {
        let view = UIImageView()
        view.contentMode = .center
        return view
    }()
    
    private let currencyView = UIView()
    
    private let currencyTitleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.caption2
        label.textColor = UIColor(resource: .nftBlack)
        label.textAlignment = .natural
        return label
    }()
    
    private let currencyNameLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.caption2
        label.textColor = UIColor(resource: .nftGreen)
        label.textAlignment = .natural
        return label
    }()
    
    // MARK: - Init
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setupUI()
        setupConstraints()
        updateSelectionAppearance()
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        nil
    }
    
    func configure(currency: UICurrency) {
        currencyImageView.image = currency.logo
        currencyTitleLabel.text = currency.title
        currencyNameLabel.text = String(currency.name.prefix(4))
    }
    
    // MARK: - Selection
    override var isSelected: Bool {
        didSet { updateSelectionAppearance() }
    }
    
    private func updateSelectionAppearance() {
        contentView.layer.borderColor = UIColor(resource: .nftBlack).cgColor
        contentView.layer.borderWidth = isSelected ? Constants.Layout.borderWidthSelected : Constants.Layout.borderWidthDefault
    }
    
    // MARK: - Setup UI
    private func setupUI() {
        contentView.backgroundColor = UIColor(resource: .nftLightGray)
        contentView.layer.cornerRadius = Constants.Layout.contentCornerRadius
        contentView.layer.masksToBounds = true
        contentView.layer.borderColor = UIColor.black.cgColor
        contentView.layer.borderWidth = Constants.Layout.borderWidthDefault
        
        contentView.addSubview(paddingView)
        
        paddingView.addSubview(paddingImageView)
        paddingView.addSubview(currencyView)
        
        paddingImageView.addSubview(currencyImageView)
        currencyView.addSubview(currencyTitleLabel)
        currencyView.addSubview(currencyNameLabel)
    }
    
    private func setupConstraints() {
        [paddingView, paddingImageView, currencyView, currencyTitleLabel, currencyNameLabel, currencyImageView].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
        }
        NSLayoutConstraint.activate([
            // paddingView
            paddingView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: Constants.Layout.paddingViewTop),
            paddingView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: Constants.Layout.paddingViewLeading),
            paddingView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor), // added to avoid ambiguous width
            paddingView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: Constants.Layout.paddingViewBottom),
            
            // currencyImage container
            paddingImageView.topAnchor.constraint(equalTo: paddingView.topAnchor),
            paddingImageView.leadingAnchor.constraint(equalTo: paddingView.leadingAnchor),
            paddingImageView.bottomAnchor.constraint(equalTo: paddingView.bottomAnchor),
            paddingImageView.widthAnchor.constraint(equalToConstant: Constants.Layout.imageContainerSide),
            paddingImageView.heightAnchor.constraint(equalToConstant: Constants.Layout.imageContainerSide),
            
            // currencyImageView inside container
            currencyImageView.topAnchor.constraint(lessThanOrEqualTo: paddingImageView.topAnchor, constant: Constants.Layout.imageInset),
            currencyImageView.leadingAnchor.constraint(lessThanOrEqualTo: paddingImageView.leadingAnchor, constant: Constants.Layout.imageInset),
            currencyImageView.trailingAnchor.constraint(greaterThanOrEqualTo: paddingImageView.trailingAnchor, constant: -Constants.Layout.imageInset),
            currencyImageView.bottomAnchor.constraint(greaterThanOrEqualTo: paddingImageView.bottomAnchor, constant: -Constants.Layout.imageInset),
            
            // currencyView
            currencyView.topAnchor.constraint(equalTo: paddingView.topAnchor),
            currencyView.trailingAnchor.constraint(equalTo: paddingView.trailingAnchor),
            currencyView.bottomAnchor.constraint(equalTo: paddingView.bottomAnchor),
            currencyView.leadingAnchor.constraint(equalTo: paddingImageView.trailingAnchor, constant: Constants.Layout.currencyViewLeading),
            
            // currencyTitleLabel
            currencyTitleLabel.topAnchor.constraint(equalTo: currencyView.topAnchor),
            currencyTitleLabel.leadingAnchor.constraint(equalTo: currencyView.leadingAnchor),
            currencyTitleLabel.trailingAnchor.constraint(lessThanOrEqualTo: currencyView.trailingAnchor),
            
            // currencyNameLabel
            currencyNameLabel.topAnchor.constraint(equalTo: currencyTitleLabel.bottomAnchor, constant: 2),
            currencyNameLabel.leadingAnchor.constraint(equalTo: currencyView.leadingAnchor),
            currencyNameLabel.trailingAnchor.constraint(lessThanOrEqualTo: currencyView.trailingAnchor),
            currencyNameLabel.bottomAnchor.constraint(equalTo: currencyView.bottomAnchor)
        ])
    }
}

private enum Constants {
    enum Layout {
        static let contentCornerRadius: CGFloat = 12
        static let borderWidthSelected: CGFloat = 1
        static let borderWidthDefault: CGFloat = 0
        static let paddingViewTop: CGFloat = 5
        static let paddingViewLeading: CGFloat = 12
        static let paddingViewBottom: CGFloat = -5
        static let imageContainerSide: CGFloat = 36
        static let imageContainerCornerRadius: CGFloat = 6
        static let currencyViewLeading: CGFloat = 4
        static let imageInset: CGFloat = 2.25
    }
}
