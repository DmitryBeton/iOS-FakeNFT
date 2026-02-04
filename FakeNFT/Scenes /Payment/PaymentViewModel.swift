//
//  PaymentViewModel.swift
//  FakeNFT
//
//  Created by Дмитрий Чалов on 02.02.2026.
//

import UIKit

/// Протокол модели представления экрана оплаты/выбора валюты.
///
/// Отвечает за загрузку списка валют (UI-моделей), предоставление данных для коллекции,
/// а также за запуск процесса оплаты через сервис оплаты.
///
/// - Threading: Коллбеки (`onItemsUpdated`, completion у `pay`) ожидаются на главном потоке,
/// так как используются для обновления UI. Текущая реализация вызывает их на главном потоке
/// благодаря мок-сервисам, но в прод-реализации рекомендуется явно документировать/гарантировать поток.
protocol PaymentViewModelProtocol: AnyObject {
    /// Текущий список UI-моделей валют, готовых к отображению.
    ///
    /// - Note: Изменение этого массива вызывает `onItemsUpdated`.
    var items: [UICurrency] { get }
    
    /// Количество элементов для удобства работы с коллекцией/таблицей.
    var itemsCount: Int { get }
    
    /// Коллбек, вызываемый при обновлении `items`.
    ///
    /// - Important: Предназначен для обновления UI, поэтому должен вызываться на главном потоке.
    var onItemsUpdated: (() -> Void)? { get set }
    
    /// Загружает исходные данные (валюты) и маппит их в `items`.
    ///
    /// - Note: В случае ошибки текущая реализация очищает список (items = []).
    /// - Important: Гарантируйте вызов `onItemsUpdated` на главном потоке.
    func loadItems()
    
    /// Возвращает UI-модель валюты по индексу, если она существует.
    /// - Parameter index: Индекс в массиве `items`.
    /// - Returns: Экземпляр `UICurrency` или `nil`, если индекс вне диапазона.
    func getUICurrency(at index: Int) -> UICurrency?
    
    /// Запускает процесс оплаты.
    ///
    /// - Parameter completion: Замыкание, вызываемое по завершении операции.
    ///   - result:
    ///     - `.success(())` — успешная оплата.
    ///     - `.failure(Error)` — ошибка оплаты (сетевая/бизнес-логика/отмена).
    ///
    /// - Important: Для обновления UI по результату вызовите completion на главном потоке.
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
