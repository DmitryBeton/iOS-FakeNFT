import UIKit

final class MenuCell: UITableViewCell, ReuseIdentifying {
    
    // MARK: - Public Methods
    
    func configure(title: String, count: Int) {
        titleLabel.text = title
        countLabel.text = "(\(count))"
    }
    
    // MARK: - Private Types
    
    private enum Constants {
        enum Layout {
            static let stackHorizontalInset: CGFloat = 16
        }
        enum Spacing {
            static let stackSpacing: CGFloat = 8
        }
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
        stackView.spacing = Constants.Spacing.stackSpacing
        stackView.alignment = .center
        stackView.distribution = .fill
        return stackView
    }()
    
    // MARK: - Init
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupViews()
        setupConstraints()
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        assertionFailure("init(coder:) has not been implemented")
        return nil
    }
    
    // MARK: - UI Methods
    
    private func setupViews() {
        contentView.backgroundColor = UIColor(resource: .nftWhite)
        selectionStyle = .none
        contentView.addSubview(stackView)
    }
    
    private func setupConstraints() {
        [stackView].disableAutoresizingMasks()
        
        NSLayoutConstraint.activate([
            stackView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            stackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: Constants.Layout.stackHorizontalInset),
            stackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -Constants.Layout.stackHorizontalInset)
        ])
    }
    
}
