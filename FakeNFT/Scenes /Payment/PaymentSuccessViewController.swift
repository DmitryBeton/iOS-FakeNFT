//
//  PaymentSuccessViewController.swift
//  FakeNFT
//
//  Created by Дмитрий Чалов on 02.02.2026.
//

import UIKit

final class PaymentSuccessViewController: UIViewController {
    private enum Constants {
        enum Layout {
            static let imageSide: CGFloat = 278
            static let imageCenterYOffset: CGFloat = -40
            static let labelTopSpacing: CGFloat = 20
            static let labelHorizontalInset: CGFloat = 36
            static let buttonBottomInset: CGFloat = 16
            static let buttonHorizontalInset: CGFloat = 16
            static let buttonHeight: CGFloat = 60
            static let cornerRadius: CGFloat = 16
        }
        enum Images {
            static let success = UIImage(resource: .success)
        }
    }

    // MARK: - Properties
    var onBackToCartTapped: (() -> Void)?

    // MARK: - UI Elements
    private let successView: UIView = UIView()

    private let imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = Constants.Images.success
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()
    
    private let label: UILabel = {
        let label = UILabel()
        label.font = UIFont.headline3
        label.text = Localization.Payment.successMessage.localized
        label.textAlignment = .center
        label.textColor = UIColor(resource: .nftBlack)
        label.numberOfLines = 2
        return label
    }()
    
    private let button: UIButton = {
        let button = UIButton()
        button.setTitle(Localization.Payment.backToCart.localized, for: .normal)
        button.setTitleColor(UIColor(resource: .nftWhite), for: .normal)
        button.titleLabel?.font = UIFont.bodyBold
        button.backgroundColor = UIColor(resource: .nftBlack)
        button.layer.cornerRadius = Constants.Layout.cornerRadius
        return button
    }()
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    // MARK: - Setup
    private func setupUI() {
        view.backgroundColor = UIColor(resource: .nftWhite)
        
        [successView ,imageView, label, button].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
        }
        view.addSubview(successView)
        view.addSubview(button)
        successView.addSubview(imageView)
        successView.addSubview(label)
        
        NSLayoutConstraint.activate([
            successView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            successView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            successView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            successView.bottomAnchor.constraint(equalTo: button.topAnchor),
            
            imageView.centerXAnchor.constraint(equalTo: successView.centerXAnchor),
            imageView.centerYAnchor.constraint(equalTo: successView.centerYAnchor, constant: Constants.Layout.imageCenterYOffset),
            imageView.widthAnchor.constraint(equalToConstant: Constants.Layout.imageSide),
            imageView.heightAnchor.constraint(equalToConstant: Constants.Layout.imageSide),
            
            label.topAnchor.constraint(equalTo: imageView.bottomAnchor, constant: Constants.Layout.labelTopSpacing),
            label.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: Constants.Layout.labelHorizontalInset),
            label.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -Constants.Layout.labelHorizontalInset),
            
            button.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -Constants.Layout.buttonBottomInset),
            button.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: Constants.Layout.buttonHorizontalInset),
            button.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -Constants.Layout.buttonHorizontalInset),
            button.heightAnchor.constraint(equalToConstant: Constants.Layout.buttonHeight)
        ])
        
        button.addTarget(self, action: #selector(backToCartTapped), for: .touchUpInside)
    }
    
    // MARK: - Actions
    @objc private func backToCartTapped() {
        onBackToCartTapped?()
    }
}

