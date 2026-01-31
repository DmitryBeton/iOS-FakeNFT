//
//  UICurrencyCollectionViewCell.swift
//  FakeNFT
//
//  Created by Дмитрий Чалов on 31.01.2026.
//

import UIKit

final class UICurrencyCollectionViewCell: UICollectionViewCell,ReuseIdentifying {
    // MARK: - UI Elements
    private let paddingView = UIView()
    
    private let paddingImageView: UIView = {
        let view = UIView()
        view.layer.cornerRadius = 6
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
        return label
    }()
    
    private let currencyNameLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.caption2
        label.textColor = UIColor(resource: .nftGreen)
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
        contentView.layer.borderColor = UIColor.black.cgColor
        contentView.layer.borderWidth = isSelected ? 1 : 0
    }

    // MARK: - Setup UI
    private func setupUI() {
        contentView.backgroundColor = UIColor(resource: .nftLightGray)
        contentView.layer.cornerRadius = 12
        contentView.layer.masksToBounds = true
        contentView.layer.borderColor = UIColor.black.cgColor
        contentView.layer.borderWidth = 0
        
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
            paddingView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 5),
            paddingView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 12),
            paddingView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -5),
            
            // currencyImage
            paddingImageView.topAnchor.constraint(equalTo: paddingView.topAnchor),
            paddingImageView.leadingAnchor.constraint(equalTo: paddingView.leadingAnchor),
            paddingImageView.bottomAnchor.constraint(equalTo: paddingView.bottomAnchor),
            paddingImageView.widthAnchor.constraint(equalToConstant: 36),
            paddingImageView.heightAnchor.constraint(equalToConstant: 36),
            
            // currencyImageView
            currencyImageView.topAnchor.constraint(lessThanOrEqualTo: paddingImageView.topAnchor, constant: 2.25),
            currencyImageView.leadingAnchor.constraint(lessThanOrEqualTo: paddingImageView.leadingAnchor, constant: 2.25),
            currencyImageView.trailingAnchor.constraint(greaterThanOrEqualTo: paddingImageView.trailingAnchor, constant: -2.25),
            currencyImageView.bottomAnchor.constraint(greaterThanOrEqualTo: paddingImageView.bottomAnchor, constant: -2.25),
            
            // currencyView
            currencyView.topAnchor.constraint(equalTo: paddingView.topAnchor),
            currencyView.trailingAnchor.constraint(equalTo: paddingView.trailingAnchor),
            currencyView.bottomAnchor.constraint(equalTo: paddingView.bottomAnchor),
            currencyView.leadingAnchor.constraint(equalTo: paddingImageView.trailingAnchor, constant: 4),
            
            // currencyTitleLabel
            currencyTitleLabel.topAnchor.constraint(equalTo: currencyView.topAnchor),
            
            // currencyValueLabel
            currencyNameLabel.bottomAnchor.constraint(equalTo: currencyView.bottomAnchor),
        ])
    }
}
