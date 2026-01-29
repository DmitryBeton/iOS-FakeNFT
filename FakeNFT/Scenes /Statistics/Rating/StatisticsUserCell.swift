import UIKit

final class StatisticsUserCell: UITableViewCell {

    static let reuseId = "StatisticsUserCell"

    private let placeLabel = UILabel()
    private let containerView = UIView()

    private let avatarImageView = UIImageView()
    private let nameLabel = UILabel()
    private let nftCountLabel = UILabel()

    private let stackView = UIStackView()
    
    private let placeholderImage = UIImage(named: "statisticAvatarTable")

    private var imageTaskId: UUID?

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
        setupLayout()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func prepareForReuse() {
        super.prepareForReuse()

        if let id = imageTaskId {
            ImageLoader.shared.cancel(id)
            imageTaskId = nil
        }

        avatarImageView.image = placeholderImage
    }

    private func setupUI() {
        selectionStyle = .none
        backgroundColor = .clear
        contentView.backgroundColor = .clear

        placeLabel.font = .systemFont(ofSize: 15, weight: .regular)
        placeLabel.textColor = UIColor(named: "nftBlackUni")
        placeLabel.textAlignment = .center
        placeLabel.translatesAutoresizingMaskIntoConstraints = false

        containerView.backgroundColor = .secondarySystemBackground
        containerView.layer.cornerRadius = 12
        containerView.translatesAutoresizingMaskIntoConstraints = false

        avatarImageView.layer.cornerRadius = 14
        avatarImageView.clipsToBounds = true
        avatarImageView.backgroundColor = .systemGray4
        avatarImageView.contentMode = .scaleAspectFill
        avatarImageView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            avatarImageView.widthAnchor.constraint(equalToConstant: 28),
            avatarImageView.heightAnchor.constraint(equalToConstant: 28)
        ])

        nameLabel.font = UIFont.systemFont(ofSize: 22, weight: .bold)
        nameLabel.textColor = .label
        nameLabel.numberOfLines = 1
        nameLabel.lineBreakMode = .byTruncatingTail
        nameLabel.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)

        nftCountLabel.font = .systemFont(ofSize: 22, weight: .bold)
        nftCountLabel.textColor = .label
        nftCountLabel.textAlignment = .right
        nftCountLabel.setContentHuggingPriority(.required, for: .horizontal)
        nftCountLabel.setContentCompressionResistancePriority(.required, for: .horizontal)

        stackView.axis = .horizontal
        stackView.alignment = .center
        stackView.spacing = 8
        stackView.translatesAutoresizingMaskIntoConstraints = false
    }

    private func setupLayout() {
        contentView.addSubview(placeLabel)
        contentView.addSubview(containerView)

        containerView.addSubview(stackView)
        stackView.addArrangedSubview(avatarImageView)
        stackView.addArrangedSubview(nameLabel)
        stackView.addArrangedSubview(nftCountLabel)

        NSLayoutConstraint.activate([
            containerView.heightAnchor.constraint(equalToConstant: 80),

            containerView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 4),
            containerView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -4),
            containerView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),

            placeLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            placeLabel.centerYAnchor.constraint(equalTo: containerView.centerYAnchor),
            placeLabel.widthAnchor.constraint(equalToConstant: 20),

            containerView.leadingAnchor.constraint(equalTo: placeLabel.trailingAnchor, constant: 8),

            stackView.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 16),
            stackView.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -16),
            stackView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 12),
            stackView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -12)
        ])
    }

    func configure(with model: StatisticsUserCellModel) {
        placeLabel.text = "\(model.place)"
        nftCountLabel.text = "\(model.nftCount)"
        nameLabel.text = model.name

        avatarImageView.image = placeholderImage

        guard let url = URL(string: model.avatarURL) else {
            return
        }

        imageTaskId = ImageLoader.shared.load(url) { [weak self] image in
            self?.avatarImageView.image = image ?? self?.placeholderImage
        }
    }
}

