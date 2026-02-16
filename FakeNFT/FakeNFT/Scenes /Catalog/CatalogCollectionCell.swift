import UIKit
import Kingfisher

final class CatalogCollectionCell: UITableViewCell {

    // MARK: - Properties
    
    static let reuseIdentifier: String = "CatalogCollectionCell"

    // MARK: - UI elements

    private let coverImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.layer.cornerRadius = 12
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()

    private let nameLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 17, weight: .bold)
        label.textColor = UIColor(resource: .nftBlack)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private let nftCountLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 17, weight: .bold)
        label.textColor = UIColor(resource: .nftBlack)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    // MARK: - Initialization

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Private methods

    private func setupUI() {
        selectionStyle = .none
        backgroundColor = UIColor(resource: .nftWhite)

        contentView.addSubview(coverImageView)
        contentView.addSubview(nameLabel)
        contentView.addSubview(nftCountLabel)

        setupConstraints()
    }

    private func setupConstraints() {
        NSLayoutConstraint.activate([
            coverImageView.topAnchor.constraint(equalTo: contentView.topAnchor),
            coverImageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            coverImageView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            coverImageView.heightAnchor.constraint(equalToConstant: 140),

            nameLabel.topAnchor.constraint(equalTo: coverImageView.bottomAnchor, constant: 4),
            nameLabel.leadingAnchor.constraint(equalTo: coverImageView.leadingAnchor),
            nameLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -21),

            nftCountLabel.centerYAnchor.constraint(equalTo: nameLabel.centerYAnchor),
            nftCountLabel.leadingAnchor.constraint(equalTo: nameLabel.trailingAnchor, constant: 4),
            nftCountLabel.trailingAnchor.constraint(lessThanOrEqualTo: contentView.trailingAnchor, constant: -16)
        ])
    }

    // MARK: - Public methods

    func configure(with model: CatalogCollectionModel) {
        nameLabel.text = model.name
        nftCountLabel.text = "(\(model.nftCount))"
        coverImageView.kf.setImage(with: model.cover)
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        coverImageView.kf.cancelDownloadTask()
        coverImageView.image = nil
    }
}
