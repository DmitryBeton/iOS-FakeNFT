import UIKit
import Kingfisher

final class CollectionDetailViewController: UIViewController {

    // MARK: - Properties

    private let viewModel: CollectionDetailViewModel

    // MARK: - UI Elements

    private let scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.contentInsetAdjustmentBehavior = .never
        return scrollView
    }()

    private let contentView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    private let coverImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.clipsToBounds = true
        imageView.contentMode = .scaleAspectFill
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.layer.cornerRadius = 12
        imageView.layer.maskedCorners = [.layerMinXMaxYCorner, .layerMaxXMaxYCorner]
        return imageView
    }()

    private lazy var backButton: UIButton = {
        let button = UIButton(type: .custom)
        button.setImage(UIImage(resource: .backButton).withRenderingMode(.alwaysTemplate), for: .normal)
        button.tintColor = UIColor(resource: .nftBlack)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(backButtonTapped), for: .touchUpInside)
        return button
    }()

    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 22, weight: .bold)
        label.textColor = UIColor(resource: .nftBlack)
        label.textAlignment = .left
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private let authorTitleLabel: UILabel = {
        let label = UILabel()
        label.text = "Автор коллекции:"
        label.font = .systemFont(ofSize: 13, weight: .regular)
        label.textColor = UIColor(resource: .nftBlack)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private let authorNameLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 15, weight: .regular)
        label.textColor = UIColor(resource: .nftBlue)
        label.translatesAutoresizingMaskIntoConstraints = false
        label.isUserInteractionEnabled = true
        return label
    }()

    private let descriptionLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 13, weight: .regular)
        label.textColor = UIColor(resource: .nftBlack)
        label.textAlignment = .left
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private let collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.minimumInteritemSpacing = 9
        layout.minimumLineSpacing = 28
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.backgroundColor = .clear
        collectionView.isScrollEnabled = false
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        return collectionView
    }()

    private lazy var activityIndicator: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView(style: .large)
        indicator.translatesAutoresizingMaskIntoConstraints = false
        return indicator
    }()

    private var collectionViewHeightConstraint: NSLayoutConstraint?

    // MARK: - Init

    init(
        collectionId: String,
        servicesAssembly: ServicesAssembly
    ) {
        self.viewModel = CollectionDetailViewModel(
            collectionId: collectionId,
            collectionService: servicesAssembly.collectionService,
            nftService: servicesAssembly.nftService
        )
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        bindViewModel()
        viewModel.viewDidLoad()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: animated)
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.setNavigationBarHidden(false, animated: animated)
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        updateCollectionViewHeight()
        scrollView.contentInset.bottom = view.safeAreaInsets.bottom
    }

    // MARK: - Private Methods

    private func setupUI() {
        view.backgroundColor = UIColor(resource: .nftWhite)

        view.addSubview(scrollView)
        view.addSubview(backButton)
        view.addSubview(activityIndicator)
        scrollView.addSubview(contentView)

        contentView.addSubview(coverImageView)
        contentView.addSubview(titleLabel)
        contentView.addSubview(authorTitleLabel)
        contentView.addSubview(authorNameLabel)
        contentView.addSubview(descriptionLabel)
        contentView.addSubview(collectionView)

        setupCollectionView()
        setupConstraints()
        setupNavigationBar()
        setupGestures()
    }

    private func setupNavigationBar() {
        navigationController?.setNavigationBarHidden(true, animated: false)

        navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
        navigationController?.navigationBar.tintColor = UIColor(resource: .nftBlack)

        let backImage = UIImage(resource: .backButton)
            .withRenderingMode(.alwaysTemplate)
        navigationController?.navigationBar.backIndicatorImage = backImage
        navigationController?.navigationBar.backIndicatorTransitionMaskImage = backImage
    }

    private func setupGestures() {
        let authorTapGesture = UITapGestureRecognizer(target: self, action: #selector(authorNameTapped))
        authorNameLabel.addGestureRecognizer(authorTapGesture)
    }

    @objc private func authorNameTapped() {
        let webViewController = AgreementWebViewController(
            urlString: "https://practicum.yandex.ru/ios-developer/?from=catalog"
        )
        navigationController?.pushViewController(webViewController, animated: true)
    }

    private func bindViewModel() {
        viewModel.onCollectionLoaded = { [weak self] collection in
            DispatchQueue.main.async {
                self?.configureWithCollection(collection)
            }
        }

        viewModel.onNFTsUpdated = { [weak self] in
            DispatchQueue.main.async {
                self?.collectionView.reloadData()
                self?.updateCollectionViewHeight()
            }
        }

        viewModel.onNFTLikeUpdated = { [weak self] index, isLiked in
            DispatchQueue.main.async {
                let indexPath = IndexPath(item: index, section: 0)
                if let cell = self?.collectionView.cellForItem(at: indexPath) as? DetailCollectionViewCell {
                    cell.setLiked(isLiked)
                }
            }
        }

        viewModel.onNFTCartUpdated = { [weak self] index, isInCart in
            DispatchQueue.main.async {
                let indexPath = IndexPath(item: index, section: 0)
                if let cell = self?.collectionView.cellForItem(at: indexPath) as? DetailCollectionViewCell {
                    cell.setInCart(isInCart)
                }
            }
        }

        viewModel.onLoadingStateChanged = { [weak self] isLoading in
            DispatchQueue.main.async {
                if isLoading {
                    self?.activityIndicator.startAnimating()
                } else {
                    self?.activityIndicator.stopAnimating()
                }
            }
        }

        viewModel.onError = { [weak self] _ in
            DispatchQueue.main.async {
                self?.showErrorAlert()
            }
        }
    }

    @objc private func backButtonTapped() {
        navigationController?.popViewController(animated: true)
    }

    private func setupCollectionView() {
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.register(
            DetailCollectionViewCell.self,
            forCellWithReuseIdentifier: DetailCollectionViewCell.reuseIdentifier
        )
    }

    private func setupConstraints() {
        let heightConstraint = collectionView.heightAnchor.constraint(equalToConstant: 0)
        collectionViewHeightConstraint = heightConstraint

        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),

            contentView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            contentView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            contentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor),

            coverImageView.topAnchor.constraint(equalTo: contentView.topAnchor),
            coverImageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            coverImageView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            coverImageView.heightAnchor.constraint(equalToConstant: 310),

            backButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 9),
            backButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 9),
            backButton.widthAnchor.constraint(equalToConstant: 24),
            backButton.heightAnchor.constraint(equalToConstant: 24),

            activityIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            activityIndicator.centerYAnchor.constraint(equalTo: view.centerYAnchor),

            titleLabel.topAnchor.constraint(equalTo: coverImageView.bottomAnchor, constant: 16),
            titleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            titleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),

            authorTitleLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 8),
            authorTitleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),

            authorNameLabel.centerYAnchor.constraint(equalTo: authorTitleLabel.centerYAnchor),
            authorNameLabel.leadingAnchor.constraint(equalTo: authorTitleLabel.trailingAnchor, constant: 4),
            authorNameLabel.trailingAnchor.constraint(lessThanOrEqualTo: contentView.trailingAnchor, constant: -16),

            descriptionLabel.topAnchor.constraint(equalTo: authorTitleLabel.bottomAnchor, constant: 5),
            descriptionLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            descriptionLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),

            collectionView.topAnchor.constraint(equalTo: descriptionLabel.bottomAnchor, constant: 24),
            collectionView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            collectionView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            collectionView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -16),
            heightConstraint
        ])
    }

    private func configureWithCollection(_ collection: NftCollection) {
        titleLabel.text = collection.name
        authorNameLabel.text = collection.author
        descriptionLabel.text = collection.description
        coverImageView.kf.setImage(with: collection.cover)
    }

    private func showErrorAlert() {
        let alert = UIAlertController(
            title: "Не удалось получить данные",
            message: nil,
            preferredStyle: .alert
        )

        alert.addAction(UIAlertAction(title: "Отмена", style: .default))

        alert.addAction(UIAlertAction(title: "Повторить", style: .default) { [weak self] _ in
            self?.viewModel.viewDidLoad()
        })

        present(alert, animated: true)
    }

    private func updateCollectionViewHeight() {
        let itemsCount = viewModel.numberOfNFTs()
        let columns: CGFloat = 3
        let itemHeight: CGFloat = 192
        let lineSpacing: CGFloat = 28

        let rows = ceil(CGFloat(itemsCount) / columns)
        let totalHeight = rows * itemHeight + (rows - 1) * lineSpacing

        collectionViewHeightConstraint?.constant = totalHeight
    }
}

// MARK: - UICollectionViewDataSource

extension CollectionDetailViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return viewModel.numberOfNFTs()
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: DetailCollectionViewCell.reuseIdentifier,
            for: indexPath
        ) as? DetailCollectionViewCell else {
            return UICollectionViewCell()
        }

        let nft = viewModel.nft(at: indexPath.item)

        cell.configure(
            imageURL: nft.imageURL,
            name: nft.name,
            rating: nft.rating,
            price: nft.price,
            isLiked: nft.isLiked,
            isInCart: nft.isInCart
        )

        cell.onLikeButtonTapped = { [weak self] in
            self?.viewModel.toggleLike(at: indexPath.item)
        }

        cell.onCartButtonTapped = { [weak self] in
            self?.viewModel.toggleCart(at: indexPath.item)
        }

        return cell
    }
}

// MARK: - UICollectionViewDelegateFlowLayout

extension CollectionDetailViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        sizeForItemAt indexPath: IndexPath
    ) -> CGSize {
        let columns: CGFloat = 3
        let spacing: CGFloat = 9
        let horizontalInsets: CGFloat = 32
        let availableWidth = view.bounds.width - horizontalInsets
        let itemWidth = (availableWidth - spacing * (columns - 1)) / columns
        let itemHeight: CGFloat = 172
        return CGSize(width: itemWidth, height: itemHeight)
    }
}
