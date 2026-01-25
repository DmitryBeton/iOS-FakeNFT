//
//  RatingView.swift
//  FakeNFT
//
//  Created by Дмитрий Чалов on 24.01.2026.
//

import UIKit

// MARK: - Rating View
final class RatingView: UIView {
    
    // MARK: - Properties
    private var rating: Int = 0 {
        didSet {
            updateStars()
        }
    }
    
    private let starSize: CGFloat = 12
    private let starSpacing: CGFloat = 2
    
    private var starImageViews: [UIImageView] = []
    
    // MARK: - Initialization
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        nil
    }
    
    // MARK: - Public Methods
    func setRating(_ rating: Int) {
        self.rating = min(max(rating, 0), 5)
    }
    
    // MARK: - Private Methods
    private func setupView() {
        for _ in 0..<5 {
            let starImageView = UIImageView()
            starImageView.contentMode = .scaleAspectFit
            starImageView.image = UIImage(systemName: "star.fill")
            starImageView.tintColor = UIColor(resource: .nftLightGray)
            starImageViews.append(starImageView)
            addSubview(starImageView)
        }
        
        setupConstraints()
    }
    
    private func setupConstraints() {
        var previousStar: UIImageView?
        
        for starImageView in starImageViews {
            starImageView.translatesAutoresizingMaskIntoConstraints = false
            
            NSLayoutConstraint.activate([
                starImageView.widthAnchor.constraint(equalToConstant: starSize),
                starImageView.heightAnchor.constraint(equalToConstant: starSize),
                starImageView.centerYAnchor.constraint(equalTo: centerYAnchor)
            ])
            
            if let previous = previousStar {
                starImageView.leadingAnchor.constraint(equalTo: previous.trailingAnchor,
                                                      constant: starSpacing).isActive = true
            } else {
                starImageView.leadingAnchor.constraint(equalTo: leadingAnchor).isActive = true
            }
            
            previousStar = starImageView
        }
        
        if let lastStar = starImageViews.last {
            lastStar.trailingAnchor.constraint(equalTo: trailingAnchor).isActive = true
        }
    }
    
    private func updateStars() {
        for (index, starImageView) in starImageViews.enumerated() {
            if index < rating {
                starImageView.tintColor = UIColor(resource: .nftYellow)
            } else {
                starImageView.tintColor = UIColor(resource: .nftLightGray)
            }
        }
    }
    
    // MARK: - Intrinsic Content Size
    override var intrinsicContentSize: CGSize {
        let width = CGFloat(5) * starSize + CGFloat(4) * starSpacing
        return CGSize(width: width, height: starSize)
    }
}
