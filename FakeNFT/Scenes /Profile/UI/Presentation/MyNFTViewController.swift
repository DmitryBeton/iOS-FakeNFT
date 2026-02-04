import UIKit

final class MyNFTViewController: UIViewController {
    
    // MARK: - Private Types
    
    private enum SortOption {
        case price
        case rating
        case name
    }
    
    // MARK: - Views
    
    private lazy var nftTableView: UITableView = {
        let tableView = UITableView()
        tableView.separatorStyle = .none
        return tableView
    }()
    
    private lazy var emptyLabel: UILabel = {
        let label = UILabel()
        label.font = .bodyBold
        label.textColor = UIColor(resource: .nftBlack)
        label.text = Localization.MyNFT.empty
        label.isHidden = true
        return label
    }()
    
    private lazy var sortBarButtonItem = UIBarButtonItem(
        image: UIImage(resource: .prSort),
        style: .plain,
        target: self,
        action: nil
    )
    
    // MARK: - Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
        setupNavigationBar()
        setupConstraints()
    }
    
    // MARK: - UI Methods
    
    private func setupViews() {
        view.backgroundColor = UIColor(resource: .nftWhite)
        view.addSubviews([
            nftTableView,
            emptyLabel
        ])
    }
    
    private func setupNavigationBar() {
        navigationItem.rightBarButtonItem = sortBarButtonItem
        navigationItem.title = Localization.MyNFT.title
    }
    
    private func setupConstraints() {
        [nftTableView].disableAutoresizingMasks()
        
        NSLayoutConstraint.activate([
            nftTableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            nftTableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            nftTableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            nftTableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
        
        emptyLabel.constraintCenters(to: view)
    }
    
}

#Preview {
    UINavigationController(rootViewController: MyNFTViewController())
}
