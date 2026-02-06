import UIKit

final class MyNftViewController: UIViewController {
    
    // MARK: - Private Types
    
    private enum SortOption {
        case price
        case rating
        case name
    }
    
    // MARK: - Views
    
    private lazy var nftTableView: UITableView = {
        let tableView = UITableView(frame: .zero, style: .grouped)
        tableView.separatorStyle = .none
        tableView.register(MyNftCell.self)
        tableView.backgroundColor = .clear
        tableView.rowHeight = 140
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
    
    // MARK: - Private Properties
    
    // TODO: - Should be changed after ViewModel implementation
    private let mockNFTs: [MyNftUI] = [
        MyNftUI(
            id: UUID(),
            name: "Lilo",
            image: URL(string: "https://code.s3.yandex.net/Mobile/iOS/NFT/Beige/April/1.png"),
            rating: 3,
            price: "36.56",
            author: "Condescending Almeida",
            isLiked: false
        ),
        MyNftUI(
            id: UUID(),
            name: "dico eleifend",
            image: URL(string: "https://code.s3.yandex.net/Mobile/iOS/NFT/Yellow/Helga/1.png"),
            rating: 5,
            price: "8.08",
            author: "Quizzical Blackwell",
            isLiked: true
        ),
        MyNftUI(
            id: UUID(),
            name: "voluptatum ius",
            image: URL(string: "https://code.s3.yandex.net/Mobile/iOS/NFT/Beige/Lark/1.png"),
            rating: 2,
            price: "49.64",
            author: "Dazzling Meninsky",
            isLiked: false
        )
    ]
    
    // MARK: - Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
        setupNavigationBar()
        setupConstraints()
        setupDelegates()
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
    
    // MARK: - Private Methods
    
    private func setupDelegates() {
        nftTableView.dataSource = self
        nftTableView.delegate = self
    }
    
}

// MARK: - TableViewDataSource

extension MyNftViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        mockNFTs.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: MyNftCell = tableView.dequeueReusableCell()
        cell.configure(nft: mockNFTs[indexPath.row])
        return cell
    }
    
}

// MARK: - TableViewDelegate

extension MyNftViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        UIView()
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        20
    }
    
}
