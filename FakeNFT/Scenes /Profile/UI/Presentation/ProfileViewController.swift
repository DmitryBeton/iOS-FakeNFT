import UIKit
import Kingfisher
import ProgressHUD

final class ProfileViewController: UIViewController, NetworkErrorView {
    
    // MARK: - Private Types
    
    private enum Menu {
        case myNft
        case favourites
        
        var title: String {
            switch self {
            case .myNft: return Localization.Profile.myNft
            case .favourites: return Localization.Profile.favourites
            }
        }
    }
    
    private enum Constants {
        enum Layout {
            static let tableViewCellHeight: CGFloat = 54
            
            static let avatarSize: CGFloat = 70
            
            static let infoStackTopInset: CGFloat = 20
            static let infoStackHorizontalInset: CGFloat = 16
            
            static let menuTopSpacing: CGFloat = 40
        }
        enum Spacing {
            static let headerStackSpacing: CGFloat = 16
            static let infoStackSpacing: CGFloat = 8
            static let infoStackCustomSpacing: CGFloat = 20
        }
    }
    
    // MARK: - Views

    private lazy var nameLabel: UILabel = {
        let label = UILabel()
        label.font = .headline3
        label.textColor = UIColor(resource: .nftBlack)
        label.adjustsFontSizeToFitWidth = true
        label.minimumScaleFactor = 0.75
        label.numberOfLines = 1
        return label
    }()
    
    private lazy var avatarImageView: AvatarView = {
        let avatarView = AvatarView()
        avatarView.contentMode = .scaleAspectFill
        avatarView.kf.indicatorType = .activity
        avatarView.image = UIImage(resource: .prDefaultAvatar)
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
        tableView.rowHeight = Constants.Layout.tableViewCellHeight
        tableView.separatorStyle = .none
        tableView.isScrollEnabled = false
        tableView.backgroundColor = .clear
        return tableView
    }()
    
    private lazy var profileHeaderStackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [avatarImageView, nameLabel])
        stackView.axis = .horizontal
        stackView.spacing = Constants.Spacing.headerStackSpacing
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
        stackView.spacing = Constants.Spacing.infoStackSpacing
        stackView.alignment = .leading
        stackView.distribution = .fill
        stackView.setCustomSpacing(Constants.Spacing.infoStackCustomSpacing, after: profileHeaderStackView)
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
    private let menu: [Menu] = [.myNft, .favourites]
    
    // MARK: - Init
    
    init(viewModel: ProfileViewModelProtocol) {
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
        appearance.titleTextAttributes = [
            .foregroundColor: UIColor(resource: .nftBlack),
            .font: UIFont.bodyBold
        ]
        
        navigationController?.navigationBar.standardAppearance = appearance
        navigationController?.navigationBar.scrollEdgeAppearance = appearance
        navigationController?.navigationBar.tintColor = UIColor(resource: .nftBlack)
    }
    
    private func setupConstraints() {
        [profileInfoStackView,
         menuTableView
        ].disableAutoresizingMasks()
        
        NSLayoutConstraint.activate([
            avatarImageView.heightAnchor.constraint(equalToConstant: Constants.Layout.avatarSize),
            avatarImageView.widthAnchor.constraint(equalToConstant: Constants.Layout.avatarSize)
        ])
        
        NSLayoutConstraint.activate([
            profileInfoStackView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: Constants.Layout.infoStackTopInset),
            profileInfoStackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: Constants.Layout.infoStackHorizontalInset),
            profileInfoStackView.trailingAnchor.constraint(lessThanOrEqualTo: view.trailingAnchor, constant: -Constants.Layout.infoStackHorizontalInset),
        ])
        
        NSLayoutConstraint.activate([
            menuTableView.topAnchor.constraint(equalTo: profileInfoStackView.bottomAnchor, constant: Constants.Layout.menuTopSpacing),
            menuTableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            menuTableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            menuTableView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
        ])
    }
    
    private func setupActions() {
        linkButton.addTarget(self, action: #selector(linkButtonTapped), for: .touchUpInside)
    }
    
    // MARK: - Actions
    
    @objc private func editBarButtonTapped() {
        let initialProfile = viewModel.getProfile()
        let servicesAssembly = viewModel.servicesAssembly
        
        let editProfileVM = EditProfileViewModel(
            profile: initialProfile,
            servicesAssembly: servicesAssembly
        )
        editProfileVM.onChangesSaved = { [weak self] in
            self?.viewModel.loadProfile()
        }
        let editProfileVC = EditProfileViewController(viewModel: editProfileVM)
        editProfileVC.hidesBottomBarWhenPushed = true
        navigationController?.pushViewController(editProfileVC, animated: true)
    }
    
    @objc private func linkButtonTapped() {
        let urlString = viewModel.websiteURLString()
        let controller = AgreementWebViewController(urlString: urlString)
        controller.hidesBottomBarWhenPushed = true
        navigationController?.pushViewController(controller, animated: true)
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
                    self?.menuTableView.reloadData()
                    
                case .failed:
                    UIBlockingProgressHUD.dismiss()
                    self?.showNetworkError() {
                        self?.viewModel.loadProfile()
                    }
                }
            }
        }
    }
    
    private func setupDelegates() {
        menuTableView.dataSource = self
        menuTableView.delegate = self
    }
    
    private func setProfile(_ profile: ProfileUI) {
        setAvatar(imageURL: profile.avatarURL)
        nameLabel.text = profile.name
        descriptionLabel.text = profile.description
        let shortLink = profile.link.shortURLString
        linkButton.setTitle(shortLink, for: .normal)
    }
    
    private func setAvatar(imageURL: URL?) {
        if let imageURL {
            avatarImageView.kf.setImage(
                with: imageURL,
                placeholder: UIImage(resource: .prPlaceholder),
                options: [.onFailureImage(UIImage(resource: .prDefaultAvatar))]
            )
        } else {
            avatarImageView.image = UIImage(resource: .prDefaultAvatar)
        }
    }
    
    private func pushToMyNftViewController() {
        let viewModel = MyNftViewModel(servicesAssembly: viewModel.servicesAssembly)
        let myNftVC = MyNftViewController(viewModel: viewModel)
        myNftVC.hidesBottomBarWhenPushed = true
        navigationController?.pushViewController(myNftVC, animated: true)
    }
    
    private func pushToFavouritesViewController() {
        let favouritesVC = FavouritesViewController()
        favouritesVC.hidesBottomBarWhenPushed = true
        navigationController?.pushViewController(favouritesVC, animated: true)
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
        case .myNft:
            cell.configure(title: item.title, count: viewModel.myNftCount())
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
        case .myNft:
            pushToMyNftViewController()
        case .favourites:
            pushToFavouritesViewController()
        }
    }
    
}
