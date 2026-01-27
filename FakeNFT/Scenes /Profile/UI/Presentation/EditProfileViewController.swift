import UIKit
import Kingfisher

final class EditProfileViewController: UIViewController {
    
    // MARK: - Views
    
    private lazy var editAvatarView: EditAvatarView = {
        let editAvatarView = EditAvatarView()
        editAvatarView.avatarView.contentMode = .scaleAspectFill
        editAvatarView.avatarView.kf.indicatorType = .activity
        return editAvatarView
    }()
    
    private lazy var nameEditStackView: EditStackView = {
        let editStackView = EditStackView()
        editStackView.titleLabel.text = Localization.Profile.editName
        return editStackView
    }()
    
    private lazy var descriptionEditStackView: EditStackView = {
        let editStackView = EditStackView()
        editStackView.titleLabel.text = Localization.Profile.editDescription
        return editStackView
    }()
    
    private lazy var websiteEditStackView: EditStackView = {
        let editStackView = EditStackView()
        editStackView.titleLabel.text = Localization.Profile.editWebsite
        return editStackView
    }()
    
    private lazy var editFieldsStackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [
            nameEditStackView, descriptionEditStackView, websiteEditStackView
        ])
        stackView.axis = .vertical
        stackView.spacing = 24
        stackView.alignment = .fill
        stackView.distribution = .fill
        return stackView
    }()
    
    private lazy var containerView: UIView = {
        let view = UIView()
        view.addSubviews([
            editAvatarView,
            editFieldsStackView
        ])
        return view
    }()
    
    private lazy var scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.addSubview(containerView)
        return scrollView
    }()
    
    private lazy var saveButton: UIButton = {
        let button = UIButton()
        button.setTitle(Localization.Profile.saveEdit, for: .normal)
        button.titleLabel?.font = .bodyBold
        button.setTitleColor(UIColor(resource: .nftWhite), for: .normal)
        button.backgroundColor = UIColor(resource: .nftBlack)
        button.layer.masksToBounds = true
        button.layer.cornerRadius = 16
        return button
    }()
    
    // MARK: - Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
        setupConstraints()
    }
    
    // MARK: - UI Methods
    
    private func setupViews() {
        view.backgroundColor = UIColor(resource: .nftWhite)
        view.addSubviews([scrollView, saveButton])
    }
    
    private func setupConstraints() {
        [scrollView,
         containerView,
         editAvatarView,
         editFieldsStackView,
         saveButton
        ].disableAutoresizingMasks()
        
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.keyboardLayoutGuide.topAnchor)
        ])
        
        NSLayoutConstraint.activate([
            containerView.topAnchor.constraint(equalTo: scrollView.contentLayoutGuide.topAnchor),
            containerView.leadingAnchor.constraint(equalTo: scrollView.frameLayoutGuide.leadingAnchor),
            containerView.trailingAnchor.constraint(equalTo: scrollView.frameLayoutGuide.trailingAnchor),
            containerView.bottomAnchor.constraint(equalTo: scrollView.contentLayoutGuide.bottomAnchor),
        ])
        
        NSLayoutConstraint.activate([
            editAvatarView.topAnchor.constraint(equalTo: containerView.topAnchor),
            editAvatarView.centerXAnchor.constraint(equalTo: containerView.centerXAnchor),
            editAvatarView.widthAnchor.constraint(equalToConstant: 72.57),
            editAvatarView.heightAnchor.constraint(equalToConstant: 70)
        ])
        
        NSLayoutConstraint.activate([
            editFieldsStackView.topAnchor.constraint(equalTo: editAvatarView.bottomAnchor, constant: 24),
            editFieldsStackView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 16),
            editFieldsStackView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -16),
            editFieldsStackView.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -24)
        ])
        
        NSLayoutConstraint.activate([
            nameEditStackView.fieldTextView.heightAnchor.constraint(equalToConstant: 44),
            descriptionEditStackView.fieldTextView.heightAnchor.constraint(equalToConstant: 132),
            websiteEditStackView.fieldTextView.heightAnchor.constraint(equalToConstant: 44)
        ])
        
        NSLayoutConstraint.activate([
            saveButton.heightAnchor.constraint(equalToConstant: 60),
            saveButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            saveButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            saveButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16)
        ])
    }
    
}

#Preview {
    EditProfileViewController()
}
