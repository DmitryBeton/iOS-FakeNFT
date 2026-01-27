import UIKit

final class EditStackView: UIStackView {
    
    // MARK: - Views
    
    lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.font = .headline3
        label.textColor = UIColor(resource: .nftBlack)
        return label
    }()
    
    lazy var fieldTextView: UITextView = {
        let textView = UITextView()
        textView.backgroundColor = UIColor(resource: .nftLightGray)
        textView.textColor = UIColor(resource: .nftBlack)
        textView.isScrollEnabled = true
        textView.font = .bodyRegular
        textView.textContainerInset = UIEdgeInsets(
            top: 11,
            left: 16,
            bottom: 11,
            right: 16
        )
        textView.layer.masksToBounds = true
        textView.layer.cornerRadius = 12
        return textView
    }()
    
    // MARK: - Init
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
    }
    
    required init(coder: NSCoder) {
        assertionFailure("init(coder:) has not been implemented")
        super.init(coder: coder)
    }
    
    // MARK: - UI Methods
    
    private func setupViews() {
        axis = .vertical
        spacing = 8
        alignment = .fill
        distribution = .fill
        
        addArrangedSubviews([titleLabel, fieldTextView])
    }
    
}
