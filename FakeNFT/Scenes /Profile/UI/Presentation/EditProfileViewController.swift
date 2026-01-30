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
        let editStackView = EditStackView(fieldType: .name, textViewDelegate: self)
        editStackView.titleLabel.text = Localization.Profile.editName
        return editStackView
    }()
    
    private lazy var descriptionEditStackView: EditStackView = {
        let editStackView = EditStackView(fieldType: .description, textViewDelegate: self)
        editStackView.titleLabel.text = Localization.Profile.editDescription
        return editStackView
    }()
    
    private lazy var websiteEditStackView: EditStackView = {
        let editStackView = EditStackView(fieldType: .website, textViewDelegate: self)
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
        button.isHidden = true
        return button
    }()
    
    private lazy var backBarButtonItem = UIBarButtonItem(
        image: UIImage(resource: .prBack),
        style: .plain,
        target: self,
        action: #selector(backButtonTapped)
    )
    
    // MARK: - Private Properties
    
    private let viewModel: EditProfileViewModelProtocol
    
    private lazy var singleTapRecognizer: UITapGestureRecognizer = {
        let recognizer = UITapGestureRecognizer(target: self, action: #selector(didSingleTap))
        recognizer.numberOfTapsRequired = 1
        recognizer.cancelsTouchesInView = false
        return recognizer
    }()
    
    // MARK: - Init
    
    init(viewModel: EditProfileViewModelProtocol) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        assertionFailure("init(coder:) has not been implemented")
        return nil
    }
    
    // MARK: - Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
        setupNavigationBar()
        setupConstraints()
        setupActions()
        bind()
        viewModel.loadProfile()
    }
    
    // MARK: - UI Methods
    
    private func setupViews() {
        view.backgroundColor = UIColor(resource: .nftWhite)
        view.addSubviews([scrollView, saveButton])
    }
    
    private func setupNavigationBar() {
        navigationItem.leftBarButtonItem = backBarButtonItem
        navigationController?.navigationBar.tintColor = UIColor(resource: .nftBlack)
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
            editAvatarView.widthAnchor.constraint(equalToConstant: 70),
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
    
    private func setupActions() {
        view.addGestureRecognizer(singleTapRecognizer)
        saveButton.addTarget(self, action: #selector(saveButtonTapped), for: .touchUpInside)
        editAvatarView.onTap = { [weak self] in
            self?.showPhotoAlert()
        }
    }
    
    // MARK: - Actions
    
    @objc private func didSingleTap() {
        view.endEditing(true)
    }
    
    @objc private func backButtonTapped() {
        if viewModel.hasChanges {
            showExitAlert()
        } else {
            navigationController?.popViewController(animated: true)
        }
    }
    
    @objc private func saveButtonTapped() {
        viewModel.saveChanges()
    }
    
    // MARK: - Private Methods
    
    private func bind() {
        viewModel.onStateChange = { [weak self] state in
            DispatchQueue.main.async {
                switch state {
                case .initial:
                    UIBlockingProgressHUD.dismiss()
                    assertionFailure("can't move to initial state")
                    
                case .initialData(let profile):
                    UIBlockingProgressHUD.dismiss()
                    self?.setProfile(profile)
                    self?.updateSaveButtonState()
                    
                case .editing:
                    UIBlockingProgressHUD.dismiss()
                    self?.updateSaveButtonState()
                    
                case .saving:
                    UIBlockingProgressHUD.show()
                    
                case .saved:
                    UIBlockingProgressHUD.dismiss()
                    self?.navigationController?.popViewController(animated: true)
                    
                case .failed:
                    UIBlockingProgressHUD.dismiss()
                    self?.showErrorAlert()
                }
            }
        }
        
        viewModel.onAvatarChange = { [weak self] in
            DispatchQueue.main.async {
                self?.updateAvatar(imageURL: self?.viewModel.profile.avatarURL)
            }
        }
    }
    
    private func setProfile(_ profile: ProfileUI) {
        updateAvatar(imageURL: profile.avatarURL)
        nameEditStackView.fieldTextView.text = profile.name
        descriptionEditStackView.fieldTextView.text = profile.description
        websiteEditStackView.fieldTextView.text = profile.link
    }
    
    private func updateAvatar(imageURL: URL?) {
        if let imageURL {
            editAvatarView.avatarView.kf.setImage(
                with: imageURL,
                placeholder: UIImage(resource: .prPlaceholder),
                options: [.onFailureImage(UIImage(resource: .prDefaultAvatar))]
            )
        } else {
            editAvatarView.avatarView.image = UIImage(resource: .prDefaultAvatar)
        }
    }
    
    private func updateSaveButtonState() {
        saveButton.isHidden = !viewModel.hasChanges
    }
    
    private func showPhotoAlert() {
        let alert = UIAlertController(
            title: nil,
            message: Localization.ProfileAlert.profilePhoto,
            preferredStyle: .actionSheet
        )
        let editAction = UIAlertAction(title: Localization.ProfileAlert.changePhoto, style: .default) { [weak self] _ in
            self?.showEditPhotoAlert()
        }
        let deleteAction = UIAlertAction(title: Localization.ProfileAlert.deletePhoto, style: .destructive) { [weak self] _ in
            self?.viewModel.changeAvatar(urlString: "")
        }
        let cancelAction = UIAlertAction(title: Localization.ProfileAlert.cancel, style: .cancel)
        
        alert.addAction(editAction)
        alert.addAction(deleteAction)
        alert.addAction(cancelAction)
        
        present(alert, animated: true)
    }
    
    private func showEditPhotoAlert() {
        let alert = UIAlertController(
            title: Localization.ProfileAlert.photoLink,
            message: nil,
            preferredStyle: .alert
        )
        alert.addTextField { [weak self] textField in
            let imageURLString = self?.viewModel.profile.avatarURL?.absoluteString
            textField.text = imageURLString
            textField.returnKeyType = .done
        }
        let cancelAction = UIAlertAction(title: Localization.ProfileAlert.cancel, style: .cancel)
        let saveAction = UIAlertAction(title: Localization.ProfileAlert.save, style: .default) { [weak self] _ in
            let newImageURLString = alert.textFields?.first?.text ?? ""
            self?.viewModel.changeAvatar(urlString: newImageURLString)
        }
        
        alert.addAction(cancelAction)
        alert.addAction(saveAction)
        
        present(alert, animated: true)
    }
    
    private func showExitAlert() {
        let alert = UIAlertController(
            title: Localization.ProfileAlert.wantToExit,
            message: nil,
            preferredStyle: .alert
        )
        let cancelAction = UIAlertAction(title: Localization.ProfileAlert.stay, style: .cancel)
        let extitAction = UIAlertAction(title: Localization.ProfileAlert.exit, style: .default) { [weak self] _ in
            self?.navigationController?.popViewController(animated: true)
        }
        
        alert.addAction(cancelAction)
        alert.addAction(extitAction)
        
        present(alert, animated: true)
    }
    
    private func showErrorAlert() {
        let alert = UIAlertController(
            title: Localization.ProfileAlert.updateError,
            message: nil,
            preferredStyle: .alert
        )
        let cancelAction = UIAlertAction(title: Localization.ProfileAlert.cancel, style: .cancel)
        let retryAction = UIAlertAction(title: Localization.ProfileAlert.retry, style: .default) { [weak self] _ in
            self?.viewModel.saveChanges()
        }
        
        alert.addAction(cancelAction)
        alert.addAction(retryAction)
        
        present(alert, animated: true)
    }
    
}

// MARK: - TextFieldDelegate

extension EditProfileViewController: UITextViewDelegate {
    
    func textView(
        _ textView: UITextView,
        shouldChangeTextIn range: NSRange,
        replacementText text: String
    ) -> Bool {
        if text == "\n" {
            textView.resignFirstResponder()
            return false
        }
        return true
    }
    
    func textViewDidChange(_ textView: UITextView) {
        guard let stackView = textView.superview as? EditStackView else { return }
        
        switch stackView.fieldType {
        case .name:
            viewModel.changeName(textView.text)
        case .description:
            viewModel.changeDescription(textView.text)
        case .website:
            viewModel.changeWebsite(urlString: textView.text)
        }
    }
    
}
