import UIKit

final class CollectionDetailViewController: UIViewController {

    // MARK: - Properties

    private let collectionId: String
    private let collectionName: String

    // MARK: - UI Elements

    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 24, weight: .bold)
        label.textColor = .textPrimary
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    // MARK: - Init

    init(collectionId: String, collectionName: String) {
        self.collectionId = collectionId
        self.collectionName = collectionName
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
        view.backgroundColor = .background

        view.addSubview(titleLabel)

        NSLayoutConstraint.activate([
            titleLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            titleLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
    }
}
