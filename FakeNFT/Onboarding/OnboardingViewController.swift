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
    
    private let pageControl: UIPageControl = {
        let control = UIPageControl()
        control.currentPageIndicatorTintColor = UIColor(resource: .nftBlack)
        control.pageIndicatorTintColor = UIColor(resource: .nftBlack).withAlphaComponent(0.3)
        control.translatesAutoresizingMaskIntoConstraints = false
        // Используем прямоугольные индикаторы (полоски)
        control.preferredIndicatorImage = UIImage(
            systemName: "minus",
            withConfiguration: UIImage.SymbolConfiguration(pointSize: 6, weight: .bold)
        )
        return control
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
        view.backgroundColor = UIColor(resource: .nftWhite)
        
        addChild(pageViewController)
        view.addSubview(pageViewController.view)
        pageViewController.view.frame = view.bounds
        pageViewController.didMove(toParent: self)
        
        view.addSubview(pageControl)
        
        NSLayoutConstraint.activate([
            pageControl.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 16),
            pageControl.centerXAnchor.constraint(equalTo: view.centerXAnchor)
        ])
    }
    
    private func setupPageControl() {
        pageControl.numberOfPages = pages.count
        pageControl.currentPage = 0
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
        guard let currentVC = viewController as? OnboardingPageViewController,
              let currentIndex = pages.firstIndex(where: { $0.text == currentVC.view.subviews.first }) else {
            return nil
        }
        
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
              let currentVC = pageViewController.viewControllers?.first as? OnboardingPageViewController,
              let index = pages.firstIndex(where: { $0.text == currentVC.view.subviews.first }) else {
            return
        }
        
        currentPageIndex = index
        pageControl.currentPage = index
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
