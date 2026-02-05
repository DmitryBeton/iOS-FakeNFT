import UIKit

final class UserCardViewController: UIViewController {

    private let viewModel: UserCardViewModelProtocol

    private let scrollView = UIScrollView()
    private let contentView = UIView()

    private let avatarImageView = UIImageView()
    private let nameLabel = UILabel()
    private let descriptionLabel = UILabel()

    private let websiteButton = UIButton(type: .system)

    private let collectionContainer = UIControl()
    private let collectionTitleLabel = UILabel()
    private let chevronImageView = UIImageView()

    private let loader = UIActivityIndicatorView(style: .medium)

    init(viewModel: UserCardViewModelProtocol) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupLayout()
        setupLoader()
        bind()
    }

    func configure(userId: String) {
        viewModel.load(userId: userId)
    }

    private func setupUI() {
        view.backgroundColor = .systemBackground
        title = "Пользователь"

        scrollView.translatesAutoresizingMaskIntoConstraints = false
        contentView.translatesAutoresizingMaskIntoConstraints = false

        view.addSubview(scrollView)
        scrollView.addSubview(contentView)

        avatarImageView.translatesAutoresizingMaskIntoConstraints = false
        avatarImageView.contentMode = .scaleAspectFill
        avatarImageView.clipsToBounds = true
        avatarImageView.layer.cornerRadius = 35
        avatarImageView.backgroundColor = .secondarySystemBackground

        nameLabel.translatesAutoresizingMaskIntoConstraints = false
        nameLabel.font = .systemFont(ofSize: 22, weight: .bold)
        nameLabel.textColor = .label
        nameLabel.numberOfLines = 2
        nameLabel.textAlignment = .center

        descriptionLabel.translatesAutoresizingMaskIntoConstraints = false
        descriptionLabel.font = .systemFont(ofSize: 15, weight: .regular)
        descriptionLabel.textColor = .secondaryLabel
        descriptionLabel.numberOfLines = 0
        descriptionLabel.textAlignment = .center

        websiteButton.translatesAutoresizingMaskIntoConstraints = false
        websiteButton.setTitle("Перейти на сайт пользователя", for: .normal)
        websiteButton.titleLabel?.font = .systemFont(ofSize: 15, weight: .medium)
        websiteButton.addTarget(self, action: #selector(websiteTapped), for: .touchUpInside)

        collectionContainer.translatesAutoresizingMaskIntoConstraints = false
        collectionContainer.backgroundColor = .secondarySystemBackground
        collectionContainer.layer.cornerRadius = 12
        collectionContainer.addTarget(self, action: #selector(collectionTapped), for: .touchUpInside)

        collectionTitleLabel.translatesAutoresizingMaskIntoConstraints = false
        collectionTitleLabel.font = .systemFont(ofSize: 17, weight: .semibold)
        collectionTitleLabel.textColor = .label

        chevronImageView.translatesAutoresizingMaskIntoConstraints = false
        chevronImageView.image = UIImage(systemName: "chevron.right")
        chevronImageView.tintColor = .tertiaryLabel

        contentView.addSubview(avatarImageView)
        contentView.addSubview(nameLabel)
        contentView.addSubview(descriptionLabel)
        contentView.addSubview(websiteButton)

        contentView.addSubview(collectionContainer)
        collectionContainer.addSubview(collectionTitleLabel)
        collectionContainer.addSubview(chevronImageView)
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

            avatarImageView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 16),
            avatarImageView.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            avatarImageView.widthAnchor.constraint(equalToConstant: 70),
            avatarImageView.heightAnchor.constraint(equalToConstant: 70),

            nameLabel.topAnchor.constraint(equalTo: avatarImageView.bottomAnchor, constant: 12),
            nameLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            nameLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),

            descriptionLabel.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: 8),
            descriptionLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            descriptionLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),

            websiteButton.topAnchor.constraint(equalTo: descriptionLabel.bottomAnchor, constant: 12),
            websiteButton.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),

            collectionContainer.topAnchor.constraint(equalTo: websiteButton.bottomAnchor, constant: 20),
            collectionContainer.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            collectionContainer.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            collectionContainer.heightAnchor.constraint(equalToConstant: 56),
            collectionContainer.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -20),

            collectionTitleLabel.leadingAnchor.constraint(equalTo: collectionContainer.leadingAnchor, constant: 16),
            collectionTitleLabel.centerYAnchor.constraint(equalTo: collectionContainer.centerYAnchor),

            chevronImageView.trailingAnchor.constraint(equalTo: collectionContainer.trailingAnchor, constant: -16),
            chevronImageView.centerYAnchor.constraint(equalTo: collectionContainer.centerYAnchor)
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

    private func bind() {
        viewModel.onLoadingChanged = { [weak self] isLoading in
            DispatchQueue.main.async {
                isLoading ? self?.loader.startAnimating() : self?.loader.stopAnimating()
            }
        }

        viewModel.onDataUpdated = { [weak self] in
            DispatchQueue.main.async {
                self?.render()
            }
        }

        viewModel.onError = { [weak self] message in
            DispatchQueue.main.async {
                let alert = UIAlertController(title: "Ошибка", message: message, preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "ОК", style: .default))
                self?.present(alert, animated: true)
            }
        }

        viewModel.onOpenWebsite = { [weak self] url in
            let web = WebViewController(url: url)
            self?.navigationController?.pushViewController(web, animated: true)
        }

        viewModel.onOpenCollection = { [weak self] userId, count in
            // TODO: Модуль "Коллекция пользователя" сделаешь дальше
            let alert = UIAlertController(
                title: "Коллекция",
                message: "Открыть коллекцию пользователя \(userId)\nNFT: \(count)",
                preferredStyle: .alert
            )
            alert.addAction(UIAlertAction(title: "ОК", style: .default))
            self?.present(alert, animated: true)
        }
    }

    private func render() {
        guard let model = viewModel.model else { return }

        nameLabel.text = model.name
        descriptionLabel.text = model.description
        collectionTitleLabel.text = "Коллекция NFT (\(model.nftCount))"

        if let url = URL(string: model.avatarURLString) {
            _ = ImageLoader.shared.load(url) { [weak self] image in
                DispatchQueue.main.async {
                    self?.avatarImageView.image = image
                }
            }
        }
    }

    @objc private func websiteTapped() {
        viewModel.websiteTapped()
    }

    @objc private func collectionTapped() {
        viewModel.collectionTapped()
    }
}

