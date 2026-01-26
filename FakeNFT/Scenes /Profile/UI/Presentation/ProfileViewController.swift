import UIKit

final class ProfileViewController: UIViewController {
    
    // MARK: - Private Types
    
    private enum Menu {
        case myNFT
        case favourites
        
        func title(count: Int) -> String {
            switch self {
            case .myNFT: return Localization.Profile.myNFT(count: count)
            case .favourites: return Localization.Profile.favourites(count: count)
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
        action: nil
    )

    // MARK: - Private Properties
    
    // TODO: Should be deleted after network implementation
    private let mockProfile = Profile(
        name: "Joaquin Phoenix",
        avatarURL: URL(string: "https://cloudflare-ipfs.com/ipfs/Qmd3W5DuhgHirLHGVixi6V76LhCkZUz6pnFt5AJBiyvHye/avatar/124.jpg"),
        description: """
            Дизайнер из Казани, люблю цифровое искусство
            и бейглы. В моей коллекции уже 100+ NFT,
            и еще больше — на моём сайте. Открыт
            к коллаборациям.
            """,
        link: URL(string: "https://practicum.yandex.ru/graphic-designer/")!,
        myNFTCount: 112,
        FavouritesCount: 11
    )
    
    // MARK: - Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        addViews()
        setupNavigationBar()
        setupConstraints()
        setProfile(mockProfile)
    }
    
    // MARK: - UI Methods
    
    private func addViews() {
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
        appearance.configureWithDefaultBackground()
        appearance.setBackIndicatorImage(
            UIImage(resource: .prBack),
            transitionMaskImage: UIImage(resource: .prBack)
        )
        
        navigationController?.navigationBar.standardAppearance = appearance
        navigationController?.navigationBar.scrollEdgeAppearance = appearance
        navigationController?.navigationBar.tintColor = UIColor(resource: .nftBlack)
    }
    
    private func setupConstraints() {
        [
            avatarImageView,
            profileInfoStackView,
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
            menuTableView.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])
    }
    
    // MARK: - Private Properties
    
    private func setProfile(_ profile: Profile) {
        avatarImageView.kf.setImage(with: profile.avatarURL, placeholder: UIImage(resource: .prDefaultAvatar))
        nameLabel.text = profile.name
        descriptionLabel.text = profile.description
        linkButton.setTitle(shortURLString(from: profile.link), for: .normal)
    }
    
    private func shortURLString(from url: URL?) -> String? {
        guard let url else { return nil }
        return url.host()?.replacingOccurrences(of: "www", with: "")
    }
    
}

#Preview {
    UINavigationController(rootViewController: ProfileViewController())
}
