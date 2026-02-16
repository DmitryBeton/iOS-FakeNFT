import UIKit

final class OnboardingViewController: UIViewController {
    
    // MARK: - Properties
    
    private let pages = OnboardingPageModel.pages()
    private var currentPageIndex = 0
    
    var onComplete: (() -> Void)?
    
    private lazy var pageViewController: UIPageViewController = {
        let pageVC = UIPageViewController(
            transitionStyle: .scroll,
            navigationOrientation: .horizontal
        )
        pageVC.dataSource = self
        pageVC.delegate = self
        return pageVC
    }()
    
    private lazy var pageControl: UIStackView = {
        let stack = UIStackView()
        stack.axis = .horizontal
        stack.spacing = 8
        stack.distribution = .fillEqually
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        setupPageControl()
        showFirstPage()
    }
    
    // MARK: - Setup
    
    private func setupView() {
        view.backgroundColor = UIColor(resource: .nftBlackUni)
        
        addChild(pageViewController)
        view.addSubview(pageViewController.view)
        pageViewController.view.frame = view.bounds
        pageViewController.didMove(toParent: self)
        
        view.addSubview(pageControl)
        
        NSLayoutConstraint.activate([
            pageControl.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 12),
            pageControl.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            pageControl.heightAnchor.constraint(equalToConstant: 4)
        ])
    }
    
    private func setupPageControl() {
        pageControl.arrangedSubviews.forEach { $0.removeFromSuperview() }

        for index in 0..<pages.count {
            let indicator = UIView()
            indicator.backgroundColor = index == 0 ? UIColor(resource: .nftWhiteUni) : UIColor(resource: .nftWhiteUni).withAlphaComponent(0.3)
            indicator.layer.cornerRadius = 2
            indicator.translatesAutoresizingMaskIntoConstraints = false

            pageControl.addArrangedSubview(indicator)

            NSLayoutConstraint.activate([
                indicator.widthAnchor.constraint(equalToConstant: 109),
                indicator.heightAnchor.constraint(equalToConstant: 4)
            ])
        }
    }
    
    private func showFirstPage() {
        let firstPage = createPageViewController(at: 0)
        pageViewController.setViewControllers(
            [firstPage],
            direction: .forward,
            animated: false
        )
    }
    
    private func createPageViewController(at index: Int) -> OnboardingPageViewController {
        let pageVC = OnboardingPageViewController(model: pages[index])
        pageVC.delegate = self
        return pageVC
    }
    
    private func updatePageControl(currentPage: Int) {
        pageControl.arrangedSubviews.enumerated().forEach { index, view in
            view.backgroundColor = index == currentPage ? UIColor(resource: .nftWhiteUni) : UIColor(resource: .nftWhiteUni).withAlphaComponent(0.3)
        }
    }

    private func completeOnboarding() {
        onComplete?()
    }
}

// MARK: - UIPageViewControllerDataSource

extension OnboardingViewController: UIPageViewControllerDataSource {
    func pageViewController(
        _ pageViewController: UIPageViewController,
        viewControllerBefore viewController: UIViewController
    ) -> UIViewController? {
        let previousIndex = currentPageIndex - 1
        guard previousIndex >= 0 else { return nil }
        return createPageViewController(at: previousIndex)
    }
    
    func pageViewController(
        _ pageViewController: UIPageViewController,
        viewControllerAfter viewController: UIViewController
    ) -> UIViewController? {
        let nextIndex = currentPageIndex + 1
        guard nextIndex < pages.count else { return nil }
        return createPageViewController(at: nextIndex)
    }
}

// MARK: - UIPageViewControllerDelegate

extension OnboardingViewController: UIPageViewControllerDelegate {
    func pageViewController(
        _ pageViewController: UIPageViewController,
        didFinishAnimating finished: Bool,
        previousViewControllers: [UIViewController],
        transitionCompleted completed: Bool
    ) {
        guard completed,
              let currentVC = pageViewController.viewControllers?.first as? OnboardingPageViewController else {
            return
        }

        if let index = pages.firstIndex(where: { $0.title == currentVC.model.title }) {
            currentPageIndex = index
            updatePageControl(currentPage: index)
        }
    }
}

// MARK: - OnboardingPageViewControllerDelegate

extension OnboardingViewController: OnboardingPageViewControllerDelegate {
    func onboardingPageDidTapClose() {
        completeOnboarding()
    }
    
    func onboardingPageDidTapAction() {
        completeOnboarding()
    }
}
