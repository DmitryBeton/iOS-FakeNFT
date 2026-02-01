//
//  PaymentViewController.swift
//  FakeNFT
//
//  Created by Дмитрий Чалов on 31.01.2026.
//

import UIKit

final class PaymentViewController: UIViewController {
    // MARK: - Properties
    private let mockData = [
        UICurrency(title: "Bitcoin", name: "BTC", logo: UIImage(resource: .bitcoin)),
        UICurrency(title: "Dogecoin", name: "DOGE", logo: UIImage(resource: .dogecoin)),
        UICurrency(title: "Tether", name: "USDT", logo: UIImage(resource: .tether)),
        UICurrency(title: "Apecoin", name: "APE", logo: UIImage(resource: .apecoin)),
        UICurrency(title: "Solana", name: "SOL", logo: UIImage(resource: .solana)),
        UICurrency(title: "Ethereum", name: "ETH", logo: UIImage(resource: .ethereum)),
        UICurrency(title: "Cardano", name: "ADA", logo: UIImage(resource: .cardano)),
        UICurrency(title: "Shiba Inu", name: "SHIB", logo: UIImage(resource: .shibaInu))
    ]
    
    // MARK: - UI Elements
    private let collection: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        let collection = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collection.backgroundColor = .clear
        collection.register(UICurrencyCollectionViewCell.self)
        return collection
    }()
    
    private let paymentFooterView = PaymentFooterView()
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.title = "Выберите способ оплаты"
        
        setupUI()
        applyNavigationTitleStyle()

    }
    
    // MARK: - Setup UI
    private func setupUI() {
        view.backgroundColor = UIColor(resource: .nftWhite)
        
        collection.delegate = self
        collection.dataSource = self
        
        view.addSubview(collection)
        view.addSubview(paymentFooterView)

        collection.translatesAutoresizingMaskIntoConstraints = false
        paymentFooterView.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            collection.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            collection.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            collection.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            collection.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            
            paymentFooterView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            paymentFooterView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            paymentFooterView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            paymentFooterView.heightAnchor.constraint(equalToConstant: 186)
        ])
    }
    
    // MARK: - Private Methods
    private func applyNavigationTitleStyle() {
        let paragraph = NSMutableParagraphStyle()
        paragraph.minimumLineHeight = 22
        paragraph.maximumLineHeight = 22
        paragraph.alignment = .center
        
        let attributes: [NSAttributedString.Key: Any] = [
            .font: UIFont.bodyBold,
            .paragraphStyle: paragraph,
            .kern: 0,
            .foregroundColor: UIColor(resource: .nftBlack)
        ]
        
        navigationController?.navigationBar.titleTextAttributes = attributes
    }
}

extension PaymentViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        mockData.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell: UICurrencyCollectionViewCell = collection.dequeueReusableCell(indexPath: indexPath)
        
        cell.configure(currency: mockData[indexPath.row])
        
        return cell
    }
}

extension PaymentViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView,
                       layout collectionViewLayout: UICollectionViewLayout,
                       sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        let padding: CGFloat = 16
        let spacing: CGFloat = 7
        let itemsPerRow: CGFloat = 2
        
        let availableWidth = collectionView.frame.width - padding * 2 - spacing * (itemsPerRow - 1)
        let widthPerItem = availableWidth / itemsPerRow
        let height = widthPerItem * 0.2738 //  height:width from figma = 0.2738

        return CGSize(width: widthPerItem, height: height)
    }
    
    func collectionView(_ collectionView: UICollectionView,
                       layout collectionViewLayout: UICollectionViewLayout,
                       insetForSectionAt section: Int) -> UIEdgeInsets {
        UIEdgeInsets(top: 16, left: 16, bottom: 16, right: 16)
    }
    
    func collectionView(_ collectionView: UICollectionView,
                       layout collectionViewLayout: UICollectionViewLayout,
                       minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        7
    }
    
    func collectionView(_ collectionView: UICollectionView,
                       layout collectionViewLayout: UICollectionViewLayout,
                       minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        7
    }
}
