import UIKit

final class CatalogCollectionCell: UITableViewCell {
    
    // MARK: - UI elements
    private lazy var containerView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(resource: .nftWhite)
        view.layer.masksToBounds = true
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
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
        backgroundColor = .clear

        contentView.addSubview(containerView)
        setupConstraints()
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            containerView.topAnchor.constraint(equalTo: contentView.topAnchor),
            containerView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            containerView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            containerView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            containerView.heightAnchor.constraint(equalToConstant: 75)
        ])
    }
    
    // MARK: - Public methods
    func configure() {
        
    }
    
}

