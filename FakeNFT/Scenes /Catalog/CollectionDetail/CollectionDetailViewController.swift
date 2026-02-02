import UIKit

final class CollectionDetailViewController: UIViewController {

    // MARK: - Properties

    private let collectionId: String
    private let collectionName: String
    private let collectionCover: UIImageView?
    private let collectionAuthor: String
    private let collectionDescription: String

    // MARK: - UI Elements
    
    private let coverCollectionImageView: UIImageView = {
        let imageView = UIImageView(image: UIImage(resource: .mockCover))
        imageView.clipsToBounds = true
        imageView.contentMode = .scaleAspectFill
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.layer.cornerRadius = 12
        imageView.layer.maskedCorners = [.layerMinXMaxYCorner, .layerMaxXMaxYCorner]
        return imageView
    }()

    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 22, weight: .bold)
        label.textColor = UIColor(resource: .nftBlack)
        label.textAlignment = .left
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let authorLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 13, weight: .regular)
        label.textColor = UIColor(resource: .nftBlack)
        label.textAlignment = .left
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let descriptionLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 13, weight: .regular)
        label.textColor = UIColor(resource: .nftBlack)
        label.textAlignment = .left
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    // MARK: - Init

    init(collectionId: String, collectionName: String, collectionCover: UIImageView? = nil, collectionAuthor: String, collectionDescription: String) {
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
        titleLabel.text = "Коллекция: \(collectionName)"
    }

    // MARK: - Setup

    private func setupUI() {
        view.backgroundColor = UIColor(resource: .nftWhite)
        
        view.addSubview(coverCollectionImageView)
        view.addSubview(titleLabel)
        view.addSubview(authorLabel)
        view.addSubview(descriptionLabel)

        NSLayoutConstraint.activate([
            
            
            titleLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            titleLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
    }
}
