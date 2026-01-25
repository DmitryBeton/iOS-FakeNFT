//
//  DeleteConfirmationAlertViewController.swift
//  FakeNFT
//
//  Created by Дмитрий Чалов on 25.01.2026.
//

import UIKit

final class DeleteConfirmationAlertViewController: UIViewController {
    // MARK: - Callbacks
    var onDeleteTapped: (() -> Void)?
    var onCancelTapped: (() -> Void)?
    
    // MARK: - UI Elements
    private let blurView: UIVisualEffectView = {
        let blurEffect = UIBlurEffect(style: .systemUltraThinMaterial)
        let view = UIVisualEffectView(effect: blurEffect)
        return view
    }()
    
    private let containerView: UIView = {
        let view = UIView()
        return view
    }()
    
    private let paddingView: UIView = {
        let view = UIView()
        return view
    }()
    
    private lazy var imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.text = Localization.Cart.confirmationOfDeletion.localized
        label.font = UIFont.caption2
        label.textColor = UIColor(resource: .nftBlack)
        label.textAlignment = .center
        label.numberOfLines = Layout.numberOfLines
        return label
    }()
    
    private let deleteButton: UIButton = {
        let button = UIButton()
        button.setTitle(Localization.Cart.deleteButton.localized, for: .normal)
        button.setTitleColor(UIColor(resource: .nftRed), for: .normal)
        button.backgroundColor = UIColor(resource: .nftBlack)
        button.titleLabel?.font = UIFont.bodyRegular
        button.layer.cornerRadius = Layout.cornerRadius
        return button
    }()
    
    private let cancelButton: UIButton = {
        let button = UIButton()
        button.setTitle(Localization.Cart.backButton.localized, for: .normal)
        button.setTitleColor(UIColor(resource: .nftWhite), for: .normal)
        button.backgroundColor = UIColor(resource: .nftBlack)
        button.titleLabel?.font = UIFont.bodyRegular
        button.layer.cornerRadius = Layout.cornerRadius
        return button
    }()
    
    private let buttonStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.spacing = Layout.buttonSpacing
        stackView.distribution = .fillEqually
        return stackView
    }()
    
    // MARK: - Initializers
    init(image: UIImage?) {
        super.init(nibName: nil, bundle: nil)
        self.imageView.image = image
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        nil
    }
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupActions()
    }
    
    // MARK: - Setup
    private func setupUI() {
        view.addSubview(blurView)
        blurView.translatesAutoresizingMaskIntoConstraints = false
        
        [containerView, imageView, titleLabel, buttonStackView, paddingView].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
        }
        
        view.addSubview(containerView)
        containerView.addSubview(paddingView)
        containerView.addSubview(buttonStackView)
        
        paddingView.addSubview(imageView)
        paddingView.addSubview(titleLabel)
        
        buttonStackView.addArrangedSubview(deleteButton)
        buttonStackView.addArrangedSubview(cancelButton)
        
        NSLayoutConstraint.activate([
            blurView.topAnchor.constraint(equalTo: view.topAnchor),
            blurView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            blurView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            blurView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            containerView.centerYAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerYAnchor),
            containerView.centerXAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerXAnchor),
            containerView.widthAnchor.constraint(equalToConstant: Layout.containerWidth),
            containerView.heightAnchor.constraint(equalToConstant: Layout.containerHeight),
            
            paddingView.topAnchor.constraint(equalTo: containerView.topAnchor),
            paddingView.centerXAnchor.constraint(equalTo: containerView.centerXAnchor),
            paddingView.widthAnchor.constraint(equalToConstant: Layout.paddingWidth),
            paddingView.heightAnchor.constraint(equalToConstant: Layout.paddingHeight),
            
            imageView.topAnchor.constraint(equalTo: paddingView.topAnchor),
            imageView.centerXAnchor.constraint(equalTo: paddingView.centerXAnchor),
            imageView.widthAnchor.constraint(equalToConstant: Layout.imageSize),
            imageView.heightAnchor.constraint(equalToConstant: Layout.imageSize),
            
            titleLabel.topAnchor.constraint(equalTo: imageView.bottomAnchor, constant: Layout.titleTopSpacing),
            titleLabel.leadingAnchor.constraint(equalTo: paddingView.leadingAnchor),
            titleLabel.trailingAnchor.constraint(equalTo: paddingView.trailingAnchor),
            
            buttonStackView.topAnchor.constraint(equalTo: paddingView.bottomAnchor, constant: Layout.buttonStackTopSpacing),
            buttonStackView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
            buttonStackView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor),
            buttonStackView.bottomAnchor.constraint(equalTo: containerView.bottomAnchor),
            
            deleteButton.heightAnchor.constraint(equalToConstant: Layout.buttonHeight),
            cancelButton.heightAnchor.constraint(equalToConstant: Layout.buttonHeight),
        ])
    }
    
    private func setupActions() {
        deleteButton.addTarget(self, action: #selector(deleteButtonTapped), for: .touchUpInside)
        cancelButton.addTarget(self, action: #selector(cancelButtonTapped), for: .touchUpInside)
    }
    
    // MARK: - Actions
    @objc private func deleteButtonTapped() {
        dismiss(animated: true) { [weak self] in
            self?.onDeleteTapped?()
        }
    }
    
    @objc private func cancelButtonTapped() {
        dismiss(animated: true) { [weak self] in
            self?.onCancelTapped?()
        }
    }
    
    // MARK: - Presentation
    func show(on viewController: UIViewController) {
        modalPresentationStyle = .overFullScreen
        modalTransitionStyle = .crossDissolve
        viewController.present(self, animated: true)
    }
}

// MARK: - Layout Constants
private enum Layout {
    static let containerWidth: CGFloat = 262
    static let containerHeight: CGFloat = 220
    
    static let paddingWidth: CGFloat = 180
    static let paddingHeight: CGFloat = 156
    
    static let imageSize: CGFloat = 108
    
    static let titleTopSpacing: CGFloat = 12
    static let buttonStackTopSpacing: CGFloat = 20
    static let buttonHeight: CGFloat = 44
    
    static let buttonSpacing: CGFloat = 8
    static let cornerRadius: CGFloat = 12
    
    static let numberOfLines = 2
}
