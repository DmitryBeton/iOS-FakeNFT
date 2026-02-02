//
//  PaymentSuccessViewController.swift
//  FakeNFT
//
//  Created by Дмитрий Чалов on 02.02.2026.
//

import UIKit

final class PaymentSuccessViewController: UIViewController {
    // MARK: - Properties
    var onBackToCartTapped: (() -> Void)?

    // MARK: - UI Elements
    private let successView: UIView = UIView()

    private let imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(resource: .success)
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()
    
    private let label: UILabel = {
        let label = UILabel()
        label.font = UIFont.headline3
        label.text = "Успех! Оплата прошла,\nпоздравляем с покупкой!"
        label.textAlignment = .center
        label.textColor = UIColor(resource: .nftBlack)
        label.numberOfLines = 2
        return label
    }()
    
    private let button: UIButton = {
        let button = UIButton()
        button.setTitle("Вернуться в корзину", for: .normal)
        button.setTitleColor(UIColor(resource: .nftWhite), for: .normal)
        button.titleLabel?.font = UIFont.bodyBold
        button.backgroundColor = UIColor(resource: .nftBlack)
        button.layer.cornerRadius = 16
        return button
    }()
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
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
            imageView.centerYAnchor.constraint(equalTo: successView.centerYAnchor, constant: -40),
            imageView.widthAnchor.constraint(equalToConstant: 278),
            imageView.heightAnchor.constraint(equalToConstant: 278),
            
            label.topAnchor.constraint(equalTo: imageView.bottomAnchor, constant: 20),
            label.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 36),
            label.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -36),
            
            button.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16),
            button.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            button.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            button.heightAnchor.constraint(equalToConstant: 60)
        ])
    }
}
