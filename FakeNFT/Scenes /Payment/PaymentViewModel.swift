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
    func pay(completion: @escaping (Result<Void, Error>) -> Void)
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
    
    private let paymentService: PaymentServiceProtocol
    
    // MARK: - Initialization
    init(paymentService: PaymentServiceProtocol = MockPaymentService()) {
        self.paymentService = paymentService
    }
    
    // MARK: - Public Methods
    func loadItems() {
        // TODO: - добавить загрузку из сети
    }
    
    func getUICurrency(at index: Int) -> UICurrency? {
        guard index < items.count else { return nil }
        return items[index]
    }
    
    func pay(completion: @escaping (Result<Void, Error>) -> Void) {
        paymentService.pay(completion: completion)
    }
}
