import UIKit

protocol OnboardingPageViewControllerDelegate: AnyObject {
    func onboardingPageDidTapClose()
    func onboardingPageDidTapAction()
}

final class OnboardingPageViewController: UIViewController {
    
    // MARK: - Properties

    private let pageView = OnboardingPageView()
    let model: OnboardingPageModel
    weak var delegate: OnboardingPageViewControllerDelegate?
    
    // MARK: - Init
    
    init(model: OnboardingPageModel) {
        self.model = model
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Lifecycle
    
    override func loadView() {
        view = pageView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        pageView.configure(with: model)
        setupActions()
    }
    
    // MARK: - Setup
    
    private func setupActions() {
        pageView.closeButton.addTarget(
            self,
            action: #selector(closeButtonTapped),
            for: .touchUpInside
        )
        
        pageView.actionButton.addTarget(
            self,
            action: #selector(actionButtonTapped),
            for: .touchUpInside
        )
    }
    
    // MARK: - Actions
    
    @objc private func closeButtonTapped() {
        delegate?.onboardingPageDidTapClose()
    }
    
    @objc private func actionButtonTapped() {
        delegate?.onboardingPageDidTapAction()
    }
}

