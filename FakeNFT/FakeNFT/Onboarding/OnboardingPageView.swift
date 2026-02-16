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

    private let gradientOverlay: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
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

    override func layoutSubviews() {
        super.layoutSubviews()
        setupGradient()
    }
    
    // MARK: - Setup

    private func setupGradient() {
        gradientOverlay.layer.sublayers?.removeAll(where: { $0 is CAGradientLayer })

        let gradientLayer = CAGradientLayer()
        gradientLayer.frame = gradientOverlay.bounds
        gradientLayer.colors = [
            UIColor.black.withAlphaComponent(0.0).cgColor,
            UIColor.black.withAlphaComponent(0.5).cgColor
        ]
        gradientLayer.locations = [0.0, 1.0]
        gradientOverlay.layer.addSublayer(gradientLayer)
    }

    private func setupView() {
        backgroundColor = UIColor(resource: .nftBlackUni)

        addSubview(imageView)
        addSubview(gradientOverlay)
        addSubview(titleLabel)
        addSubview(textLabel)
        addSubview(closeButton)
        addSubview(actionButton)
        
        NSLayoutConstraint.activate([
            imageView.topAnchor.constraint(equalTo: topAnchor),
            imageView.leadingAnchor.constraint(equalTo: leadingAnchor),
            imageView.trailingAnchor.constraint(equalTo: trailingAnchor),
            imageView.bottomAnchor.constraint(equalTo: bottomAnchor),

            gradientOverlay.topAnchor.constraint(equalTo: topAnchor),
            gradientOverlay.leadingAnchor.constraint(equalTo: leadingAnchor),
            gradientOverlay.trailingAnchor.constraint(equalTo: trailingAnchor),
            gradientOverlay.bottomAnchor.constraint(equalTo: bottomAnchor),

            closeButton.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor, constant: 16),
            closeButton.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),
            closeButton.widthAnchor.constraint(equalToConstant: 44),
            closeButton.heightAnchor.constraint(equalToConstant: 44),

            titleLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            titleLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),
            titleLabel.bottomAnchor.constraint(equalTo: textLabel.topAnchor, constant: -12),

            textLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            textLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),
            textLabel.bottomAnchor.constraint(equalTo: actionButton.topAnchor, constant: -363),

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
