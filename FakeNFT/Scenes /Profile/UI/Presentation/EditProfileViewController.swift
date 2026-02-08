import UIKit
import Kingfisher

final class EditProfileViewController: UIViewController {
    
    // MARK: - Private Types
    
    private enum Constants {
        enum Layout {
            static let editAvatarSize: CGFloat = 70
            
            static let inputFieldsVerticalInset: CGFloat = 24
            static let inputFieldsHorizontalInset: CGFloat = 16
            
            static let saveButtonHeight: CGFloat = 60
            static let saveButtonHorizontalInset: CGFloat = 16
            static let saveButtonBottomInset: CGFloat = 16
        }
        enum Spacing {
            static let inputFieldsSpacing: CGFloat = 24
        }
        enum Radius {
            static let buttonRadius: CGFloat = 16
        }
    }
    
    // MARK: - Views
    
    private lazy var editAvatarView: EditAvatarView = {
        let editAvatarView = EditAvatarView()
        editAvatarView.avatarView.contentMode = .scaleAspectFill
        editAvatarView.avatarView.kf.indicatorType = .activity
        return editAvatarView
    }()
    
    private lazy var nameInputView: ProfileInputView = {
        let inputView = ProfileInputView(inputType: .textField)
        inputView.title = Localization.Profile.editName
        return inputView
    }()
    
    private lazy var descriptionInputView: ProfileInputView = {
        let inputView = ProfileInputView(inputType: .textView)
        inputView.title = Localization.Profile.editDescription
        return inputView
    }()
    
    private lazy var websiteInputView: ProfileInputView = {
        let inputView = ProfileInputView(inputType: .textField)
        inputView.title = Localization.Profile.editWebsite
        return inputView
    }()
    
    private lazy var inputFieldsStackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [
            nameInputView, descriptionInputView, websiteInputView
        ])
        stackView.axis = .vertical
        stackView.spacing = Constants.Spacing.inputFieldsSpacing
        stackView.alignment = .fill
        stackView.distribution = .fill
        return stackView
    }()
    
    private lazy var containerView: UIView = {
        let view = UIView()
        view.addSubviews([
            editAvatarView,
            inputFieldsStackView
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
        button.layer.cornerRadius = Constants.Radius.buttonRadius
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
    
    @available(*, unavailable)
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
         inputFieldsStackView,
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
            editAvatarView.widthAnchor.constraint(equalToConstant: Constants.Layout.editAvatarSize),
            editAvatarView.heightAnchor.constraint(equalToConstant: Constants.Layout.editAvatarSize)
        ])
        
        NSLayoutConstraint.activate([
            inputFieldsStackView.topAnchor.constraint(equalTo: editAvatarView.bottomAnchor, constant: Constants.Layout.inputFieldsVerticalInset),
            inputFieldsStackView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: Constants.Layout.inputFieldsHorizontalInset),
            inputFieldsStackView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -Constants.Layout.inputFieldsHorizontalInset),
            inputFieldsStackView.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -Constants.Layout.inputFieldsVerticalInset)
        ])
        
        NSLayoutConstraint.activate([
            saveButton.heightAnchor.constraint(equalToConstant: Constants.Layout.saveButtonHeight),
            saveButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: Constants.Layout.saveButtonHorizontalInset),
            saveButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -Constants.Layout.saveButtonHorizontalInset),
            saveButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -Constants.Layout.saveButtonBottomInset)
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
        
        bindInputViews()
    }
    
    private func setProfile(_ profile: ProfileUI) {
        updateAvatar(imageURL: profile.avatarURL)
        nameInputView.inputText = profile.name
        descriptionInputView.inputText = profile.description
        websiteInputView.inputText = profile.link
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
    
    private func bindInputViews() {
        nameInputView.onTextChange = { [weak self] text in
            self?.viewModel.changeName(text)
        }
        descriptionInputView.onTextChange = { [weak self] text in
            self?.viewModel.changeDescription(text)
        }
        websiteInputView.onTextChange = { [weak self] text in
            self?.viewModel.changeWebsite(urlString: text)
        }
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
