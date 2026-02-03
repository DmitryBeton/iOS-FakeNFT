import UIKit

final class CollectionDetailViewController: UIViewController {

    // MARK: - Properties

    private let collectionId: String
    private let collectionName: String
    private let collectionCover: URL?
    private let collectionAuthor: String
    private let collectionDescription: String

    // Mock data для проверки вёрстки
    private let mockNFTs: [(name: String, price: String, rating: Int, isLiked: Bool, isInCart: Bool)] = [
        ("Archie", "1 ETH", 2, true, false),
        ("Ruby", "1 ETH", 2, true, true),
        ("Nacho", "1 ETH", 2, true, false),
        ("Biscuit", "1 ETH", 1, false, false),
        ("Daisy", "1 ETH", 3, true, false),
        ("Susan", "1 ETH", 2, false, false)
    ]

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
        let imageView = UIImageView(image: UIImage(resource: .mockCover))
        imageView.clipsToBounds = true
        imageView.contentMode = .scaleAspectFill
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.layer.cornerRadius = 12
        imageView.layer.maskedCorners = [.layerMinXMaxYCorner, .layerMaxXMaxYCorner]
        return imageView
    }()

    private lazy var backButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(resource: .backButton), for: .normal)
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

    private var collectionViewHeightConstraint: NSLayoutConstraint?

    // MARK: - Init

    init(
        collectionId: String,
        collectionName: String,
        collectionCover: URL? = nil,
        collectionAuthor: String = "",
        collectionDescription: String = ""
    ) {
        self.collectionId = collectionId
        self.collectionName = collectionName
        self.collectionCover = collectionCover
        self.collectionAuthor = collectionAuthor
        self.collectionDescription = collectionDescription
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        configureWithData()
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

    // MARK: - Setup

    private func setupUI() {
        view.backgroundColor = UIColor(resource: .nftWhite)
        
        view.addSubview(scrollView)
        view.addSubview(backButton)
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
    }

    private func setupNavigationBar() {
        navigationController?.setNavigationBarHidden(true, animated: false)
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

    private func configureWithData() {
        titleLabel.text = collectionName.isEmpty ? "Peach" : collectionName
        authorNameLabel.text = collectionAuthor.isEmpty ? "John Doe" : collectionAuthor
        descriptionLabel.text = collectionDescription.isEmpty
            ? "Персиковый — как облака над закатным солнцем в океане. В этой коллекции совмещены трогательная нежность и живая игривость сказочных зефирных зверей."
            : collectionDescription
    }

    private func updateCollectionViewHeight() {
        let itemsCount = mockNFTs.count
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
        return mockNFTs.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: DetailCollectionViewCell.reuseIdentifier,
            for: indexPath
        ) as? DetailCollectionViewCell else {
            return UICollectionViewCell()
        }

        let nft = mockNFTs[indexPath.item]
        cell.configure(
            imageURL: nil,
            name: nft.name,
            rating: nft.rating,
            price: nft.price,
            isLiked: nft.isLiked,
            isInCart: nft.isInCart
        )

        return cell
    }
}

// MARK: - UICollectionViewDelegate

extension CollectionDetailViewController: UICollectionViewDelegate {

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
