import UIKit

final class EditAvatarView: UIView {
    
    // MARK: - Views
    
    lazy var avatarView = AvatarView()
    
    private lazy var editIconImageView: UIImageView = {
        let image = UIImage(resource: .prEditAvatar)
        let imageView = UIImageView(image: image)
        return imageView
    }()
    
    // MARK: - Init
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
        setupConstraints()
    }
    
    required init?(coder: NSCoder) {
        assertionFailure("init(coder:) has not been implemented")
        return nil
    }
    
    // MARK: - UI Methods
    
    private func setupViews() {
        addSubviews([avatarView, editIconImageView])
    }
    
    private func setupConstraints() {
        [avatarView, editIconImageView].disableAutoresizingMasks()
        
        NSLayoutConstraint.activate([
            avatarView.heightAnchor.constraint(equalToConstant: 70),
            avatarView.widthAnchor.constraint(equalToConstant: 70),
        ])
        avatarView.constraintCenters(to: self)
        
        NSLayoutConstraint.activate([
            editIconImageView.trailingAnchor.constraint(equalTo: self.trailingAnchor),
            editIconImageView.bottomAnchor.constraint(equalTo: self.bottomAnchor)
        ])
    }
    
}
