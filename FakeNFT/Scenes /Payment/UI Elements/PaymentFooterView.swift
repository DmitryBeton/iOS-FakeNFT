//
//  PaymentFooterView.swift
//  FakeNFT
//
//  Created by Дмитрий Чалов on 01.02.2026.
//

import UIKit

final class PaymentFooterView: UIView {
    
    // MARK: - Properties
    var onPayTapped: (() -> Void)?
    var onAgreementTapped: (() -> Void)?
    
    var isPayEnabled: Bool {
        get { payButton.isEnabled }
        set {
            payButton.isEnabled = newValue
            updatePayButtonAppearance()
        }
    }
    
    // MARK: - UI Elements
    private let agreementView = UIView()
    
    private let agreementLabel: UILabel = {
        let label = UILabel()
        label.text = Constants.Text.agreementPrefix
        label.font = UIFont.caption2
        label.textColor = UIColor(resource: .nftBlack)
        return label
    }()
    
    private let linkLabel: UILabel = {
        let label = UILabel()
        label.text = Constants.Text.agreementLink
        label.font = UIFont.caption2
        label.textColor = UIColor(resource: .nftBlue)
        label.isUserInteractionEnabled = true
        return label
    }()
    
    private lazy var payButton: UIButton = {
        let button = UIButton()
        button.setTitle(Constants.Text.payButton, for: .normal)
        button.setTitleColor(UIColor(resource: .nftWhite), for: .normal)
        button.titleLabel?.font = UIFont.bodyBold
        button.backgroundColor = UIColor(resource: .nftBlack)
        button.layer.cornerRadius = Constants.Layout.cornerRadius
        button.addTarget(self, action: #selector(processPayment), for: .touchUpInside)
        button.isEnabled = false
        return button
    }()
    
    // MARK: - Init
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
        setupGestures()
        updatePayButtonAppearance()
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        nil
    }
    
    // MARK: - Setup UI
    private func setupView() {
        layer.cornerRadius = Constants.Layout.cornerRadius
        backgroundColor = UIColor(resource: .nftLightGray)
        
        [agreementView, agreementLabel, linkLabel, payButton].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
        }
        
        addSubview(agreementView)
        addSubview(payButton)
        agreementView.addSubview(agreementLabel)
        agreementView.addSubview(linkLabel)
        
        NSLayoutConstraint.activate([
            agreementView.topAnchor.constraint(equalTo: self.topAnchor, constant: Constants.Layout.contentInset),
            agreementView.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: Constants.Layout.contentInset),
            agreementView.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -Constants.Layout.contentInset),
            
            agreementLabel.topAnchor.constraint(equalTo: agreementView.topAnchor),
            agreementLabel.leadingAnchor.constraint(equalTo: agreementView.leadingAnchor),
            
            linkLabel.topAnchor.constraint(equalTo: agreementLabel.bottomAnchor, constant: Constants.Layout.linkTopSpacing),
            linkLabel.leadingAnchor.constraint(equalTo: agreementLabel.leadingAnchor),
            
            payButton.topAnchor.constraint(equalTo: agreementView.bottomAnchor, constant: Constants.Layout.payTopSpacing),
            payButton.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: Constants.Layout.payLeadingInset),
            payButton.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -Constants.Layout.payTrailingInset),
            payButton.bottomAnchor.constraint(equalTo: safeAreaLayoutGuide.bottomAnchor, constant: -Constants.Layout.payBottomInset),
            payButton.widthAnchor.constraint(equalToConstant: Constants.Layout.payWidth),
            payButton.heightAnchor.constraint(equalToConstant: Constants.Layout.payHeight)
        ])
    }
    
    private func setupGestures() {
        let tap = UITapGestureRecognizer(target: self, action: #selector(linkTapped))
        linkLabel.addGestureRecognizer(tap)
    }
    
    private func updatePayButtonAppearance() {
        payButton.alpha = payButton.isEnabled ? 1.0 : 0.5
    }
    
    // MARK: - Actions
    @objc
    private func processPayment() {
        onPayTapped?()
    }
    
    @objc
    private func linkTapped() {
        onAgreementTapped?()
    }
}

private enum Constants {
    enum Text {
        static let agreementPrefix = Localization.Payment.agreementPrefix.localized
        static let agreementLink = Localization.Payment.agreementLink.localized
        static let payButton = Localization.Payment.payButton.localized
    }
    enum Layout {
        static let cornerRadius: CGFloat = 16
        static let contentInset: CGFloat = 16
        static let linkTopSpacing: CGFloat = 4
        static let payTopSpacing: CGFloat = 16
        static let payLeadingInset: CGFloat = 20
        static let payTrailingInset: CGFloat = 12
        static let payBottomInset: CGFloat = 16
        static let payWidth: CGFloat = 343
        static let payHeight: CGFloat = 60
    }
}
