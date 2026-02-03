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
    var onItemsUpdated: (() -> Void)? { get set }
    func loadItems()
    
    func getUICurrency(at index: Int) -> UICurrency?
    func pay(completion: @escaping (Result<Void, Error>) -> Void)
}

final class PaymentViewModel: PaymentViewModelProtocol {
    
    // MARK: - Backing storage
    private var currencyItems: [Currency] = [] {
        didSet {
            items = currencyItems.map { self.mapToUI($0) }
        }
    }

    // MARK: - Properties
    var items: [UICurrency] = [] {
        didSet {
            onItemsUpdated?()
        }
    }
    
    var itemsCount: Int { items.count }
    var onItemsUpdated: (() -> Void)?

    private let paymentService: PaymentServiceProtocol
    private let currencyService: CurrencyServiceProtocol
    
    // MARK: - Initialization
    init(paymentService: PaymentServiceProtocol = MockPaymentService(),
         currencyService: CurrencyServiceProtocol = MockCurrencyService()) {
        self.paymentService = paymentService
        self.currencyService = currencyService
    }
    
    func loadItems() {
        currencyService.fetchCurrencies { [weak self] result in
            guard let self else { return }
            switch result {
            case .success(let currencies):
                self.currencyItems = currencies
            case .failure:
                self.currencyItems = []
            }
        }
    }
    
    // MARK: - Public Methods
    
    func getUICurrency(at index: Int) -> UICurrency? {
        guard index < items.count else { return nil }
        return items[index]
    }
    
    func pay(completion: @escaping (Result<Void, Error>) -> Void) {
        paymentService.pay(completion: completion)
    }
    
    // MARK: - Mapping
    private func mapToUI(_ currency: Currency) -> UICurrency {
        let image = UIImage(named: currency.logo)
        return UICurrency(
            title: currency.title,
            name: currency.name,
            logo: image
        )
    }
}
