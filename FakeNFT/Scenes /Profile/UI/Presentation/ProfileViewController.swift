import UIKit
import Kingfisher
import ProgressHUD

final class ProfileViewController: UIViewController {
    
    // MARK: - Private Types
    
    private enum Menu {
        case myNFT
        case favourites
        
        var title: String {
            switch self {
            case .myNFT: return Localization.Profile.myNFT
            case .favourites: return Localization.Profile.favourites
            }
        }
    }
    
    // MARK: - Views

    private lazy var nameLabel: UILabel = {
        let label = UILabel()
        label.font = .headline3
        label.textColor = UIColor(resource: .nftBlack)
        label.minimumScaleFactor = 0.5
        return label
    }()
    
    private lazy var avatarImageView: AvatarView = {
        let avatarView = AvatarView()
        avatarView.contentMode = .scaleAspectFill
        avatarView.kf.indicatorType = .activity
        return avatarView
    }()
    
    private lazy var descriptionLabel: UILabel = {
        let label = UILabel()
        label.font = .caption2
        label.textColor = UIColor(resource: .nftBlack)
        label.numberOfLines = 5
        label.lineBreakMode = .byTruncatingTail
        return label
    }()
    
    private lazy var linkButton: UIButton = {
        let button = UIButton()
        button.setTitleColor(UIColor(resource: .nftBlue), for: .normal)
        button.titleLabel?.font = .caption1
        return button
    }()
    
    private lazy var menuTableView: UITableView = {
        let tableView = UITableView()
        tableView.register(MenuCell.self)
        tableView.rowHeight = 54
        tableView.separatorStyle = .none
        tableView.isScrollEnabled = false
        return tableView
    }()
    
    private lazy var profileHeaderStackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [avatarImageView, nameLabel])
        stackView.axis = .horizontal
        stackView.spacing = 16
        stackView.alignment = .center
        stackView.distribution = .fill
        return stackView
    }()
    
    private lazy var profileInfoStackView: UIStackView = {
        let stackView = UIStackView(
            arrangedSubviews: [
                profileHeaderStackView,
                descriptionLabel,
                linkButton
            ]
        )
        stackView.axis = .vertical
        stackView.spacing = 8
        stackView.alignment = .leading
        stackView.distribution = .fill
        stackView.setCustomSpacing(20, after: profileHeaderStackView)
        return stackView
    }()
    
    private lazy var editBarButtonItem = UIBarButtonItem(
        image: UIImage(resource: .prEdit),
        style: .plain,
        target: self,
        action: #selector(editBarButtonTapped)
    )

    // MARK: - Private Properties
    
    private let viewModel: ProfileViewModelProtocol
    private let menu: [Menu] = [.myNFT, .favourites]
    
    // MARK: - Init
    
    init(viewModel: ProfileViewModelProtocol) {
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
        setupDelegates()
        bind()
        viewModel.loadProfile()
    }
    
    // MARK: - UI Methods
    
    private func setupViews() {
        view.backgroundColor = UIColor(resource: .nftWhite)
        view.addSubviews([
            profileInfoStackView,
            menuTableView
        ])
    }
    
    private func setupNavigationBar() {
        navigationItem.rightBarButtonItem = editBarButtonItem
        navigationItem.backButtonDisplayMode = .minimal
        
        let appearance = UINavigationBarAppearance()
        appearance.configureWithTransparentBackground()
        appearance.setBackIndicatorImage(
            UIImage(resource: .prBack),
            transitionMaskImage: UIImage(resource: .prBack)
        )
        
        navigationController?.navigationBar.standardAppearance = appearance
        navigationController?.navigationBar.scrollEdgeAppearance = appearance
        navigationController?.navigationBar.tintColor = UIColor(resource: .nftBlack)
    }
    
    private func setupConstraints() {
        [profileInfoStackView,
         menuTableView
        ].disableAutoresizingMasks()
        
        NSLayoutConstraint.activate([
            avatarImageView.heightAnchor.constraint(equalToConstant: 70),
            avatarImageView.widthAnchor.constraint(equalToConstant: 70)
        ])
        
        NSLayoutConstraint.activate([
            profileInfoStackView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            profileInfoStackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            profileInfoStackView.trailingAnchor.constraint(lessThanOrEqualTo: view.trailingAnchor, constant: -16),
        ])
        
        NSLayoutConstraint.activate([
            menuTableView.topAnchor.constraint(equalTo: profileInfoStackView.bottomAnchor, constant: 40),
            menuTableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            menuTableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            menuTableView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
        ])
    }
    
    // MARK: - Actions
    
    @objc private func editBarButtonTapped() {
        let initialProfile = viewModel.getProfile()
        let editProfileVM = EditProfileViewModel(profile: initialProfile)
        editProfileVM.onChangesSaved = { [weak self] in
            self?.viewModel.loadProfile()
        }
        let editProfileVC = EditProfileViewController(viewModel: editProfileVM)
        
        navigationController?.pushViewController(editProfileVC, animated: true)
    }
    
    // MARK: - Private Methods
    
    private func bind() {
        viewModel.onStateChange = { [weak self] state in
            DispatchQueue.main.async {
                switch state {
                case .initial:
                    UIBlockingProgressHUD.dismiss()
                    assertionFailure("can't move to initial state")
                    
                case .loading:
                    UIBlockingProgressHUD.show()
                    
                case .data(let profile):
                    UIBlockingProgressHUD.dismiss()
                    self?.setProfile(profile)
                    
                case .failed:
                    UIBlockingProgressHUD.dismiss()
                    self?.showErrorAlert()
                }
            }
        }
    }
    
    private func setupDelegates() {
        menuTableView.dataSource = self
        menuTableView.delegate = self
    }
    
    private func setProfile(_ profile: ProfileUI) {
        avatarImageView.kf.setImage(with: profile.avatarURL, placeholder: UIImage(resource: .prDefaultAvatar))
        nameLabel.text = profile.name
        descriptionLabel.text = profile.description
        let shortLink = shortURLString(from: URL(string: profile.link))
        linkButton.setTitle(shortLink, for: .normal)
    }
    
    private func shortURLString(from url: URL?) -> String {
        guard let url else { return "" }
        return url.host()?.replacingOccurrences(of: "www", with: "") ?? ""
    }
    
    private func pushToMyNFTViewController() {
        let myNFTVC = MyNFTViewController()
        navigationController?.pushViewController(myNFTVC, animated: true)
    }
    
    private func pushToFavouritesViewController() {
        let favouritesVC = FavouritesViewController()
        navigationController?.pushViewController(favouritesVC, animated: true)
    }
    
    private func showErrorAlert() {
        let alert = UIAlertController(
            title: Localization.ProfileAlert.loadError,
            message: nil,
            preferredStyle: .alert
        )
        let cancelAction = UIAlertAction(title: Localization.ProfileAlert.cancel, style: .cancel)
        let retryAction = UIAlertAction(title: Localization.ProfileAlert.retry, style: .default) { [weak self] _ in
            self?.viewModel.loadProfile()
        }
        
        alert.addAction(cancelAction)
        alert.addAction(retryAction)
        
        present(alert, animated: true)
    }
    
}

// MARK: - TableViewDataSource

extension ProfileViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        menu.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: MenuCell = tableView.dequeueReusableCell()
        let item = menu[indexPath.row]
        switch item {
        case .myNFT:
            cell.configure(title: item.title, count: viewModel.myNFTCount())
        case .favourites:
            cell.configure(title: item.title, count: viewModel.favouritesCount())
        }
        return cell
    }
    
}

// MARK: - TableViewDelegate

extension ProfileViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let item = menu[indexPath.row]
        switch item {
        case .myNFT:
            pushToMyNFTViewController()
        case .favourites:
            pushToFavouritesViewController()
        }
    }
    
}
