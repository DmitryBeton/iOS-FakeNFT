import UIKit

final class MenuCell: UITableViewCell, ReuseIdentifying {
    
    // MARK: - Public Methods
    
    func configure(title: String, count: Int) {
        titleLabel.text = title
        countLabel.text = "(\(count))"
    }
    
    // MARK: - Views
    
    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.font = .bodyBold
        label.textColor = UIColor(resource: .nftBlack)
        return label
    }()
    
    private lazy var countLabel: UILabel = {
        let label = UILabel()
        label.font = .bodyBold
        label.textColor = UIColor(resource: .nftBlack)
        return label
    }()
    
    private lazy var chevronImageView: UIImageView = {
        let image = UIImage(resource: .prChevronForward)
        let imageView = UIImageView(image: image)
        imageView.tintColor = UIColor(resource: .nftBlack)
        return imageView
    }()
    
    private lazy var stackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [
            titleLabel, countLabel, UIView(), chevronImageView
        ])
        stackView.axis = .horizontal
        stackView.spacing = 8
        stackView.alignment = .center
        stackView.distribution = .fill
        return stackView
    }()
    
    // MARK: - Init
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupBehavior()
        setupViews()
        setupConstraints()
    }
    
    required init?(coder: NSCoder) {
        assertionFailure("init(coder:) has not been implemented")
        return nil
    }
    
    // MARK: - UI Methods
    
    private func setupBehavior() {
        selectionStyle = .none
    }
    
    private func setupViews() {
        contentView.addSubview(stackView)
    }
    
    private func setupConstraints() {
        [stackView].disableAutoresizingMasks()
        
        NSLayoutConstraint.activate([
            stackView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            stackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            stackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16)
        ])
    }
    
}
