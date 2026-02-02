//
//  PaymentViewModel.swift
//  FakeNFT
//
//  Created by Дмитрий Чалов on 02.02.2026.
//

import UIKit

protocol PaymentViewModelProtocol: AnyObject {
    var items: [UICurrency] { get }
    var itemsCount: Int { get }
    func loadItems()
    func getUICurrency(at index: Int) -> UICurrency?
}

final class PaymentViewModel: PaymentViewModelProtocol {
    // MARK: - Properties
    var items: [UICurrency] = [
        UICurrency(title: "Bitcoin", name: "BTC", logo: UIImage(resource: .bitcoin)),
        UICurrency(title: "Dogecoin", name: "DOGE", logo: UIImage(resource: .dogecoin)),
        UICurrency(title: "Tether", name: "USDT", logo: UIImage(resource: .tether)),
        UICurrency(title: "Apecoin", name: "APE", logo: UIImage(resource: .apecoin)),
        UICurrency(title: "Solana", name: "SOL", logo: UIImage(resource: .solana)),
        UICurrency(title: "Ethereum", name: "ETH", logo: UIImage(resource: .ethereum)),
        UICurrency(title: "Cardano", name: "ADA", logo: UIImage(resource: .cardano)),
        UICurrency(title: "Shiba Inu", name: "SHIB", logo: UIImage(resource: .shibaInu))
    ]
    
    var itemsCount: Int { items.count }

    // MARK: - Public Methods
    func loadItems() {
        // TODO: - добавить загрузку из сети
    }
    
    func getUICurrency(at index: Int) -> UICurrency? {
        guard index < items.count else { return nil }
        return items[index]
    }

    
}
