//
//  OrderSummaryView.swift
//  FakeNFT
//
//  Created by Дмитрий Чалов on 25.01.2026.
//

import UIKit

final class OrderSummaryView: UIView {
    // MARK: - Properties
    private var count: Int = 0 {
        didSet {
            updateCount()
        }
    }
    
    private var totalPrice: Double = 0 {
        didSet {
            updateTotalPrice()
        }
    }

    // MARK: - UI Elements
    private let totalView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(resource: .nftLightGray)
        
        if #available(iOS 26.0, *) {
            view.layer.cornerRadius = Layout.Style.cornerRadius
        } else {
            view.layer.cornerRadius = Layout.Style.cornerRadius
            view.layer.maskedCorners = [
                .layerMinXMinYCorner,
                .layerMaxXMinYCorner
            ]
        }
        view.layer.masksToBounds = true
        return view
    }()
    
    private let paddingView: UIView = {
        let view = UIView()
        return view
    }()
    
    private let priceView: UIView = {
        let view = UIView()
        return view
    }()

    private let totalCountLabel: UILabel = {
        let label = UILabel()
        label.textColor = UIColor(resource: .nftBlack)
        label.font = UIFont.caption1
        label.text = "0 NFT"
        return label
    }()
    
    private let totalPriceLabel: UILabel = {
        let label = UILabel()
        label.text = "0,00"
        label.font = UIFont.bodyBold
        label.textColor = UIColor(resource: .nftGreen)
        return label
    }()
    
    private let payButton: UIButton = {
        let button = UIButton()
        button.setTitle(Localization.Cart.payButton.localized, for: .normal)
        button.titleLabel?.font = UIFont.bodyBold
        button.setTitleColor(UIColor(resource: .nftWhite), for: .normal)
        button.backgroundColor = UIColor(resource: .nftBlack)
        button.layer.cornerRadius = Layout.Style.cornerRadius
        return button
    }()

    // MARK: - Initialization
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        nil
    }
    
    // MARK: - Setup UI
    private func setupView() {
        [totalView, paddingView, priceView,
         payButton, totalCountLabel, totalPriceLabel].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
        }
        
        addSubview(totalView)
        totalView.addSubview(paddingView)
        
        paddingView.addSubview(priceView)
        paddingView.addSubview(payButton)

        priceView.addSubview(totalCountLabel)
        priceView.addSubview(totalPriceLabel)
        
        NSLayoutConstraint.activate([
            // TotalView
            totalView.topAnchor.constraint(equalTo: topAnchor),
            totalView.leadingAnchor.constraint(equalTo: leadingAnchor),
            totalView.trailingAnchor.constraint(equalTo: trailingAnchor),
            totalView.bottomAnchor.constraint(equalTo: bottomAnchor),
            
            // PaddingView
            paddingView.topAnchor.constraint(equalTo: totalView.topAnchor, constant: Layout.Spacing.padding),
            paddingView.leadingAnchor.constraint(equalTo: totalView.leadingAnchor, constant: Layout.Spacing.padding),
            paddingView.trailingAnchor.constraint(equalTo: totalView.trailingAnchor, constant: -Layout.Spacing.padding),
            paddingView.bottomAnchor.constraint(equalTo: totalView.bottomAnchor, constant: -Layout.Spacing.padding),
            
            // PriceView
            priceView.leadingAnchor.constraint(equalTo: paddingView.leadingAnchor),
            priceView.centerYAnchor.constraint(equalTo: paddingView.centerYAnchor),
            
            // totalCountLabel
            totalCountLabel.topAnchor.constraint(equalTo: priceView.topAnchor),
            totalCountLabel.leadingAnchor.constraint(equalTo: priceView.leadingAnchor),
            totalCountLabel.trailingAnchor.constraint(equalTo: priceView.trailingAnchor),
            
            // totalPriceLabel
            totalPriceLabel.topAnchor.constraint(equalTo: totalCountLabel.bottomAnchor, constant: Layout.Spacing.priceToCount),
            totalPriceLabel.leadingAnchor.constraint(equalTo: priceView.leadingAnchor),
            totalPriceLabel.trailingAnchor.constraint(equalTo: priceView.trailingAnchor),
            totalPriceLabel.bottomAnchor.constraint(equalTo: priceView.bottomAnchor),
            
            // payButton
            payButton.trailingAnchor.constraint(equalTo: paddingView.trailingAnchor),
            payButton.centerYAnchor.constraint(equalTo: paddingView.centerYAnchor),
            payButton.widthAnchor.constraint(equalToConstant: Layout.Size.width),
            payButton.heightAnchor.constraint(equalToConstant: Layout.Size.height),
            
            payButton.leadingAnchor.constraint(greaterThanOrEqualTo: priceView.trailingAnchor, constant: Layout.Spacing.buttonToPrice)
        ])

    }

    // MARK: - Private Methods
    private func updateCount() {
        totalCountLabel.text = "\(count) NFT"
    }
    
    private func updateTotalPrice() {
        totalPriceLabel.text = "\(totalPrice) ETH"
    }
    
    // MARK: - Public Methods
    func updateOrderSummary(count: Int, price: Double) {
        self.count = max(0, count)
        self.totalPrice = max(0, price)
    }
}

private enum Layout {
    enum Size {
        static let width: CGFloat = 240
        static let height: CGFloat = 44
    }
    
    enum Spacing {
        static let buttonToPrice: CGFloat = 16
        static let padding: CGFloat = 16
        static let priceToCount: CGFloat = 2
    }
    
    enum Style {
        static let cornerRadius: CGFloat = 16
    }
}
