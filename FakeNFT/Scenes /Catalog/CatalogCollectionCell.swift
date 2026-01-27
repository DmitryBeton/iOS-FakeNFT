import UIKit

final class CatalogCollectionCell: UITableViewCell {
    
    // MARK: - Properties
    static let reuseIdentifier: String = "CatalogCollectionCell"
    
    // MARK: - UI elements

    private let coverImagesStackView: UIStackView = {
        let stack = UIStackView()
        stack.axis = .horizontal
        stack.distribution = .fillEqually
        stack.spacing = 0
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.layer.cornerRadius = 12
        stack.clipsToBounds = true
        return stack
    }()

    private let firstImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        return imageView
    }()

    private let secondImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        return imageView
    }()

    private let thirdImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        return imageView
    }()

    private let nameLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 17, weight: .bold)
        label.textColor = .textPrimary
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private let nftCountLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 17, weight: .regular)
        label.textColor = .textPrimary
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
        backgroundColor = .background

        // Добавляем imageView в stackView
        coverImagesStackView.addArrangedSubview(firstImageView)
        coverImagesStackView.addArrangedSubview(secondImageView)
        coverImagesStackView.addArrangedSubview(thirdImageView)

        contentView.addSubview(coverImagesStackView)
        contentView.addSubview(nameLabel)
        contentView.addSubview(nftCountLabel)

        setupConstraints()
    }

    private func setupConstraints() {
        NSLayoutConstraint.activate([
            // StackView с картинками
            coverImagesStackView.topAnchor.constraint(equalTo: contentView.topAnchor),
            coverImagesStackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            coverImagesStackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            coverImagesStackView.heightAnchor.constraint(equalToConstant: 140),

            // Название коллекции
            nameLabel.topAnchor.constraint(equalTo: coverImagesStackView.bottomAnchor, constant: 4),
            nameLabel.leadingAnchor.constraint(equalTo: coverImagesStackView.leadingAnchor),
            nameLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -16),

            // Количество NFT (справа от названия)
            nftCountLabel.centerYAnchor.constraint(equalTo: nameLabel.centerYAnchor),
            nftCountLabel.leadingAnchor.constraint(equalTo: nameLabel.trailingAnchor, constant: 4),
            nftCountLabel.trailingAnchor.constraint(lessThanOrEqualTo: contentView.trailingAnchor, constant: -16)
        ])
    }
    
    // MARK: - Public methods

    func configure(with model: CatalogCollectionModel) {
        nameLabel.text = model.name
        nftCountLabel.text = "(\(model.nftCount))"

        // Загружаем 3 изображения
        if model.coverImages.count >= 3 {
            // Пробуем загрузить из Assets, если нет - создаём цветной плейсхолдер
            firstImageView.image = UIImage(named: model.coverImages[0]) ?? createPlaceholder(color: .systemPink)
            secondImageView.image = UIImage(named: model.coverImages[1]) ?? createPlaceholder(color: .systemBlue)
            thirdImageView.image = UIImage(named: model.coverImages[2]) ?? createPlaceholder(color: .systemGreen)
        }

        // Потом здесь будет загрузка через Kingfisher:
        // if model.coverImages.count >= 3 {
        //     firstImageView.kf.setImage(with: URL(string: model.coverImages[0]))
        //     secondImageView.kf.setImage(with: URL(string: model.coverImages[1]))
        //     thirdImageView.kf.setImage(with: URL(string: model.coverImages[2]))
        // }
    }

    // MARK: - Helper methods

    private func createPlaceholder(color: UIColor) -> UIImage {
        let size = CGSize(width: 100, height: 100)
        let renderer = UIGraphicsImageRenderer(size: size)
        return renderer.image { context in
            color.setFill()
            context.fill(CGRect(origin: .zero, size: size))
        }
    }
    
}

