import UIKit

final class OnboardingPageView: UIView {
    
    // MARK: - UI Elements
    
    private let imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 32, weight: .bold)
        label.textColor = UIColor(resource: .nftWhiteUni)
        label.numberOfLines = 1
        label.textAlignment = .left
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let textLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 15, weight: .regular)
        label.textColor = UIColor(resource: .nftWhiteUni)
        label.numberOfLines = 2
        label.textAlignment = .left
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    let closeButton: UIButton = {
        let button = UIButton(type: .custom)
        button.setImage(UIImage(resource: .close), for: .normal)
        button.tintColor = UIColor(resource: .nftWhiteUni)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    let actionButton: UIButton = {
        let button = UIButton(type: .custom)
        button.setImage(UIImage(resource: .onboardingButton), for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    // MARK: - Init
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Setup
    
    private func setupView() {
        backgroundColor = UIColor(resource: .nftBlackUni)
        
        addSubview(imageView)
        addSubview(titleLabel)
        addSubview(textLabel)
        addSubview(closeButton)
        addSubview(actionButton)
        
        NSLayoutConstraint.activate([
            imageView.topAnchor.constraint(equalTo: topAnchor),
            imageView.leadingAnchor.constraint(equalTo: leadingAnchor),
            imageView.trailingAnchor.constraint(equalTo: trailingAnchor),
            imageView.heightAnchor.constraint(equalTo: heightAnchor, multiplier: 0.6),

            closeButton.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor, constant: 16),
            closeButton.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),
            closeButton.widthAnchor.constraint(equalToConstant: 44),
            closeButton.heightAnchor.constraint(equalToConstant: 44),

            titleLabel.topAnchor.constraint(equalTo: imageView.bottomAnchor, constant: 24),
            titleLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            titleLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),

            textLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 12),
            textLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            textLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),

            actionButton.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            actionButton.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),
            actionButton.bottomAnchor.constraint(equalTo: safeAreaLayoutGuide.bottomAnchor, constant: -50),
            actionButton.heightAnchor.constraint(equalToConstant: 60)
        ])
    }
    
    // MARK: - Configure
    
    func configure(with model: OnboardingPageModel) {
        imageView.image = model.image
        titleLabel.text = model.title
        textLabel.text = model.text
        closeButton.isHidden = !model.showCloseButton
        actionButton.isHidden = !model.showActionButton
    }
}
