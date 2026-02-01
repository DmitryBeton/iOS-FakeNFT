//
//  PaymentFooterView.swift
//  FakeNFT
//
//  Created by Дмитрий Чалов on 01.02.2026.
//

import UIKit

final class PaymentFooterView: UIView {
    // MARK: - UI Elements
    private let agreementView = UIView()
    
    private let agreementLabel: UILabel = {
        let label = UILabel()
        label.text = "Совершая покупку, вы соглашаетесь с условиями"
        label.font = UIFont.caption2
        label.textColor = UIColor(resource: .nftBlack)
        return label
    }()
    
    private let linkLabel: UILabel = {
        let label = UILabel()
        label.text = "Пользовательского соглашения"
        label.font = UIFont.caption2
        label.textColor = UIColor(resource: .nftBlue)
        return label
    }()

    private let payButton: UIButton = {
        let button = UIButton()
        button.setTitle("Оплатить", for: .normal)
        button.setTitleColor(UIColor(resource: .nftWhite), for: .normal)
        button.titleLabel?.font = UIFont.bodyBold
        button.backgroundColor = UIColor(resource: .nftBlack)
        button.layer.cornerRadius = 16
        return button
    }()
    
    // MARK: - Init
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
        layer.cornerRadius = 16
        backgroundColor = UIColor(resource: .nftLightGray)
        
        [agreementView, agreementLabel, linkLabel,
         payButton].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
        }
        
        addSubview(agreementView)
        addSubview(payButton)
        agreementView.addSubview(agreementLabel)
        agreementView.addSubview(linkLabel)
        
        NSLayoutConstraint.activate([
            agreementView.topAnchor.constraint(equalTo: self.topAnchor, constant: 16),
            agreementView.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 16),
            agreementView.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -16),

            agreementLabel.topAnchor.constraint(equalTo: agreementView.topAnchor),
            agreementLabel.leadingAnchor.constraint(equalTo: agreementView.leadingAnchor),
            
            linkLabel.topAnchor.constraint(equalTo: agreementLabel.bottomAnchor, constant: 4),
            linkLabel.leadingAnchor.constraint(equalTo: agreementLabel.leadingAnchor),

            payButton.topAnchor.constraint(equalTo: agreementView.bottomAnchor, constant: 16),
            payButton.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 20),
            payButton.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -12),
            payButton.bottomAnchor.constraint(equalTo: safeAreaLayoutGuide.bottomAnchor, constant: -16),
            payButton.widthAnchor.constraint(equalToConstant: 343),
            payButton.heightAnchor.constraint(equalToConstant: 60)
        ])

    }
}
