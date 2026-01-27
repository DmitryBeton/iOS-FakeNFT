import UIKit

final class CatalogCollectionCell: UITableViewCell {
    
    // MARK: - Properties
    static let reuseIdentifier: String = "CatalogCollectionCell"
    
    // MARK: - UI elements
    
    private let coverImageView = UIImageView()
    private let nameLabel = UILabel()
    private let nftCountLabel = UILabel()
    
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
        contentView.addSubview(coverImageView)
        contentView.addSubview(nameLabel)
        contentView.addSubview(nftCountLabel)
        
        // TODO: Добавить constraints
        // coverImageView.translatesAutoresizingMaskIntoConstraints = false
        // NSLayoutConstraint.activate([...])
    }
    
    // MARK: - Public methods
    
    func configure(with model: CatalogCollectionModel) {
        nameLabel.text = model.name
        nftCountLabel.text = "\(model.nftCount) NFTs"
        
        // Пока используем placeholder или моковое изображение
        coverImageView.image = UIImage(named: model.coverImageUrl)
        // Потом здесь будет загрузка через Kingfisher:
        // coverImageView.kf.setImage(with: URL(string: model.coverImageUrl))
    }
    
}

