import UIKit

final class UserCollectionViewController: UIViewController {

    private let viewModel: UserCollectionViewModel

    private let loader = UIActivityIndicatorView(style: .large)
    private lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.minimumInteritemSpacing = 8
        layout.minimumLineSpacing = 8

        let cv = UICollectionView(frame: .zero, collectionViewLayout: layout)
        cv.translatesAutoresizingMaskIntoConstraints = false
        cv.backgroundColor = .systemBackground
        cv.dataSource = self
        cv.delegate = self
        cv.register(UserCollectionNftCell.self)
        return cv
    }()

    init(viewModel: UserCollectionViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) { nil }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        title = "Коллекция NFT"

        setupUI()
        bind()
        viewModel.load()
    }

    private func setupUI() {
        loader.translatesAutoresizingMaskIntoConstraints = false

        view.addSubview(collectionView)
        view.addSubview(loader)

        NSLayoutConstraint.activate([
            collectionView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            collectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor),

            loader.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            loader.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
    }

    private func bind() {
        viewModel.onLoadingChanged = { [weak self] isLoading in
            if isLoading {
                self?.loader.startAnimating()
                self?.collectionView.isHidden = true
            } else {
                self?.loader.stopAnimating()
                self?.collectionView.isHidden = false
            }
        }

        viewModel.onItemsChanged = { [weak self] in
            self?.collectionView.reloadData()
        }

        viewModel.onError = { [weak self] message in
            let alert = UIAlertController(title: "Ошибка", message: message, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "ОК", style: .default))
            self?.present(alert, animated: true)
        }
    }
}

extension UserCollectionViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        viewModel.items.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell: UserCollectionNftCell = collectionView.dequeueReusableCell(indexPath: indexPath)
        let item = viewModel.items[indexPath.item]

        cell.configure(
            imageURL: item.imageURL,
            name: item.name,
            rating: item.rating,
            price: item.priceText,
            isLiked: item.isLiked,
            isInCart: item.isInCart
        )

        cell.onLikeButtonTapped = { [weak self] in
            self?.viewModel.toggleLike(at: indexPath.item)
        }

        cell.onCartTap = { [weak self] in
            self?.viewModel.toggleCart(at: indexPath.row)
        }

        return cell
    }
}

extension UserCollectionViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {

        let spacing: CGFloat = 8
        let columns: CGFloat = 3

        let totalSpacing = spacing * (columns - 1)
        let width = collectionView.bounds.width
        let itemWidth = floor((width - totalSpacing) / columns)

        return CGSize(width: itemWidth, height: itemWidth + 80)
    }
}

