import UIKit

enum CartItemShimmerHelper {
    private static let shimmerLayerName = "cart.shimmer.layer"
    private static let shimmerAnimationKey = "cart.shimmer.animation"

    static func start(
        in views: [UIView],
        imageView: UIView,
        imageCornerRadius: CGFloat,
        textCornerRadius: CGFloat
    ) {
        for view in views {
            let cornerRadius = view === imageView ? imageCornerRadius : textCornerRadius
            addShimmer(to: view, cornerRadius: cornerRadius)
        }
    }

    static func stop(in views: [UIView]) {
        views.forEach { view in
            view.layer.sublayers?
                .filter { $0.name == shimmerLayerName }
                .forEach { $0.removeFromSuperlayer() }
        }
    }

    static func updateFrames(in views: [UIView]) {
        views.forEach { view in
            view.layer.sublayers?
                .filter { $0.name == shimmerLayerName }
                .forEach { $0.frame = view.bounds }
        }
    }

    private static func addShimmer(to view: UIView, cornerRadius: CGFloat) {
        guard !view.bounds.isEmpty else { return }

        let baseColor = UIColor(resource: .nftLightGray).cgColor
        let highlightColor = UIColor(resource: .nftWhite).withAlphaComponent(0.7).cgColor

        let gradient = CAGradientLayer()
        gradient.name = shimmerLayerName
        gradient.frame = view.bounds
        gradient.cornerRadius = cornerRadius
        gradient.colors = [baseColor, highlightColor, baseColor]
        gradient.locations = [0.0, 0.5, 1.0]
        gradient.startPoint = CGPoint(x: 0, y: 0.5)
        gradient.endPoint = CGPoint(x: 1, y: 0.5)

        let animation = CABasicAnimation(keyPath: "locations")
        animation.fromValue = [-1.0, -0.5, 0.0]
        animation.toValue = [1.0, 1.5, 2.0]
        animation.duration = 1.1
        animation.repeatCount = .infinity
        gradient.add(animation, forKey: shimmerAnimationKey)

        view.layer.addSublayer(gradient)
    }
}
