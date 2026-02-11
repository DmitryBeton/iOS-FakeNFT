import UIKit

final class UserCardViewController: UIViewController {

    // MARK: - Dependencies
    private let viewModel: UserCardViewModelProtocol
    private let servicesAssembly: ServicesAssembly

    // MARK: - UI
    private let scrollView = UIScrollView()
    private let contentView = UIView()

    private let mainStack = UIStackView()
    private let headerStack = UIStackView()

    private let avatarImageView = UIImageView()
    private let nameLabel = UILabel()
    private let descriptionLabel = UILabel()

    private let siteButton = UIButton(type: .system)

    private let collectionRow = UIButton(type: .system)
    private let collectionStack = UIStackView()
    private let collectionLabel = UILabel()
    private let collectionChevron = UIImageView(image: UIImage(systemName: "chevron.right"))

    private let loader = UIActivityIndicatorView(style: .medium)

    // MARK: - Init
    init(viewModel: UserCardViewModelProtocol, servicesAssembly: ServicesAssembly) {
        self.viewModel = viewModel
        self.servicesAssembly = servicesAssembly
        super.init(nibName: nil, bundle: nil)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) { nil }

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        hidesBottomBarWhenPushed = true
        setupUI()
        setupLayout()
        setupLoader()
        bindViewModel()
    }

    func configure(userId: String) {
        viewModel.load(userId: userId)
    }

    // MARK: - Setup UI
    private func setupUI() {
        view.backgroundColor = .systemBackground

        // Scroll
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        contentView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)

        // Main stack
        mainStack.translatesAutoresizingMaskIntoConstraints = false
        mainStack.axis = .vertical
        mainStack.alignment = .fill
        mainStack.spacing = 16
        contentView.addSubview(mainStack)

        // Header stack
        headerStack.translatesAutoresizingMaskIntoConstraints = false
        headerStack.axis = .horizontal
        headerStack.alignment = .center
        headerStack.spacing = 16

        // Avatar
        avatarImageView.translatesAutoresizingMaskIntoConstraints = false
        avatarImageView.contentMode = .scaleAspectFill
        avatarImageView.clipsToBounds = true
        avatarImageView.layer.cornerRadius = 35
        avatarImageView.image = UIImage(resource: .statisticAvatarTable)

        NSLayoutConstraint.activate([
            avatarImageView.widthAnchor.constraint(equalToConstant: 70),
            avatarImageView.heightAnchor.constraint(equalToConstant: 70)
        ])

        // Name
        nameLabel.translatesAutoresizingMaskIntoConstraints = false
        nameLabel.font = .systemFont(ofSize: 22, weight: .semibold)
        nameLabel.textColor = .label
        nameLabel.numberOfLines = 1
        nameLabel.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)

        headerStack.addArrangedSubview(avatarImageView)
        headerStack.addArrangedSubview(nameLabel)
        headerStack.addArrangedSubview(UIView())

        // Description
        descriptionLabel.translatesAutoresizingMaskIntoConstraints = false
        descriptionLabel.font = .systemFont(ofSize: 15)
        descriptionLabel.textColor = UIColor(named: "nftBlack")
        descriptionLabel.numberOfLines = 0

        // Site button
        siteButton.translatesAutoresizingMaskIntoConstraints = false
        siteButton.setTitle("Перейти на сайт пользователя", for: .normal)
        siteButton.setTitleColor(.label, for: .normal)
        siteButton.titleLabel?.font = .systemFont(ofSize: 15, weight: .medium)
        siteButton.layer.cornerRadius = 20
        siteButton.layer.borderWidth = 1
        siteButton.layer.borderColor = UIColor(named: "nftBlack")?.cgColor
        siteButton.addTarget(self, action: #selector(siteTapped), for: .touchUpInside)

        NSLayoutConstraint.activate([
            siteButton.heightAnchor.constraint(equalToConstant: 40)
        ])

        // Collection row
        collectionRow.translatesAutoresizingMaskIntoConstraints = false
        collectionRow.addTarget(self, action: #selector(collectionTapped), for: .touchUpInside)

        NSLayoutConstraint.activate([
            collectionRow.heightAnchor.constraint(equalToConstant: 54)
        ])

        // Collection content
        collectionStack.translatesAutoresizingMaskIntoConstraints = false
        collectionStack.axis = .horizontal
        collectionStack.alignment = .center
        collectionStack.spacing = 8
        collectionStack.isUserInteractionEnabled = false

        collectionLabel.font = .systemFont(ofSize: 17, weight: .semibold)
        collectionChevron.tintColor = .tertiaryLabel

        collectionStack.addArrangedSubview(collectionLabel)
        collectionStack.addArrangedSubview(UIView())
        collectionStack.addArrangedSubview(collectionChevron)

        collectionRow.addSubview(collectionStack)

        NSLayoutConstraint.activate([
            collectionStack.leadingAnchor.constraint(equalTo: collectionRow.leadingAnchor, constant: 16),
            collectionStack.trailingAnchor.constraint(equalTo: collectionRow.trailingAnchor, constant: -16),
            collectionStack.topAnchor.constraint(equalTo: collectionRow.topAnchor),
            collectionStack.bottomAnchor.constraint(equalTo: collectionRow.bottomAnchor)
        ])

        // Add arranged views
        mainStack.addArrangedSubview(headerStack)
        mainStack.addArrangedSubview(descriptionLabel)
        mainStack.addArrangedSubview(siteButton)
        mainStack.addArrangedSubview(collectionRow)

        siteButton.widthAnchor.constraint(equalTo: mainStack.widthAnchor).isActive = true
        collectionRow.widthAnchor.constraint(equalTo: mainStack.widthAnchor).isActive = true
    }

    private func setupLayout() {
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),

            contentView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            contentView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            contentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor),

            mainStack.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 16),
            mainStack.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            mainStack.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            mainStack.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -20),
        ])
    }

    private func setupLoader() {
        loader.hidesWhenStopped = true
        loader.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(loader)

        NSLayoutConstraint.activate([
            loader.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            loader.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
    }

    // MARK: - Bind
    private func bindViewModel() {
        viewModel.onLoadingChanged = { [weak self] isLoading in
            DispatchQueue.main.async {
                isLoading ? self?.loader.startAnimating() : self?.loader.stopAnimating()
            }
        }

        viewModel.onDataUpdated = { [weak self] in
            DispatchQueue.main.async { self?.render() }
        }

        viewModel.onError = { [weak self] message in
            DispatchQueue.main.async {
                let alert = UIAlertController(title: "Ошибка", message: message, preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "ОК", style: .default))
                self?.present(alert, animated: true)
            }
        }

        viewModel.onOpenCollection = { [weak self] userId, _ in
            guard let self else { return }

            let vc = UserCollectionModule.make(
                userId: userId,
                servicesAssembly: self.servicesAssembly
            )

            self.navigationController?.pushViewController(vc, animated: true)
        }

        viewModel.onOpenWebsite = { [weak self] url in
            guard let self else { return }
            let vc = AgreementWebViewController(urlString: url.absoluteString)
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }

    private func render() {
        guard let model = viewModel.model else { return }

        nameLabel.text = model.name
        descriptionLabel.text = model.description
        collectionLabel.text = "Коллекция NFT (\(model.nftCount))"

        if let url = URL(string: model.avatarURLString) {
            _ = ImageLoader.shared.load(url) { [weak self] image in
                DispatchQueue.main.async {
                    self?.avatarImageView.image = image ?? UIImage(named: "statisticAvatarTable")
                }
            }
        } else {
            avatarImageView.image = UIImage(named: "statisticAvatarTable")
        }
    }

    // MARK: - Actions
    @objc private func siteTapped() {
        viewModel.websiteTapped()
    }

    @objc private func collectionTapped() {
        viewModel.collectionTapped()
    }
}

