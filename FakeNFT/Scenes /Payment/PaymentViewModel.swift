//
//  PaymentViewModel.swift
//  FakeNFT
//
//  Created by Дмитрий Чалов on 02.02.2026.
//

import UIKit
import OSLog

/// Состояния экрана оплаты (FSM)
enum PaymentViewState {
    case idle
    case loadingCurrencies
    case currenciesLoaded(items: [UICurrency])
    case empty
    case paying
    case paid
    case error(error: PaymentError)
}

enum PaymentError: Error {
    case networkOffline
    case paymentFailed
    case currenciesLoadFailed
    case server(code: Int)
    case unknown(underlying: Error)
}

/// Протокол модели представления экрана оплаты/выбора валюты.
///
/// Отвечает за загрузку списка валют (UI-моделей), предоставление данных для коллекции,
/// а также за запуск процесса оплаты через сервис оплаты.
///
/// - Threading: Коллбеки (`onStateChange`, completion у `pay`) ожидаются на главном потоке,
/// так как используются для обновления UI. Текущая реализация вызывает их на главном потоке
/// благодаря мок-сервисам, но в прод-реализации рекомендуется явно документировать/гарантировать поток.
protocol PaymentViewModelProtocol: AnyObject {
    /// Текущий список UI-моделей валют, готовых к отображению.
    ///
    /// - Note: Изменение этого массива вызывает обновление состояния.
    var items: [UICurrency] { get }

    /// Количество элементов для удобства работы с коллекцией/таблицей.
    var itemsCount: Int { get }

    /// Текущее состояние экрана оплаты.
    var state: PaymentViewState { get }

    /// Коллбек, вызываемый при изменении состояния.
    ///
    /// - Important: Предназначен для обновления UI, поэтому должен вызываться на главном потоке.
    var onStateChange: ((PaymentViewState) -> Void)? { get set }

    /// Загружает исходные данные (валюты) и маппит их в `items`.
    ///
    /// - Note: В случае ошибки текущая реализация очищает список (items = []) и выставляет состояние ошибки.
    /// - Important: Гарантируйте вызов `onStateChange` на главном потоке.
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

    private static let logger = Logger(subsystem: "com.fakenft.app", category: "PaymentViewModel")

    // MARK: - Backing storage
    private var currencyItems: [Currency] = [] {
        didSet {
            Self.logger.debug("currencyItems didSet. newCount=\(self.currencyItems.count)")
            items = currencyItems.map { self.mapToUI($0) }
            Self.logger.debug("Mapped currencies to UI items. count=\(self.items.count)")
            if items.isEmpty {
                state = .empty
            } else {
                state = .currenciesLoaded(items: items)
            }
        }
    }

    // MARK: - Properties
    var items: [UICurrency] = []

    var itemsCount: Int { items.count }
    private(set) var state: PaymentViewState = .idle {
        didSet {
            onStateChange?(state)
        }
    }
    var onStateChange: ((PaymentViewState) -> Void)?

    private let paymentService: PaymentServiceProtocol
    private let currencyService: CurrencyServiceProtocol
    private let cartService: CartServiceProtocol

    // MARK: - Initialization
    init(paymentService: PaymentServiceProtocol = MockPaymentService(),
         currencyService: CurrencyServiceProtocol = MockCurrencyService(),
         cartService: CartServiceProtocol = CartService()) {
        self.paymentService = paymentService
        self.currencyService = currencyService
        self.cartService = cartService
    }

    func loadItems() {
        Self.logger.info("Loading currencies started")
        state = .loadingCurrencies
        currencyService.fetchCurrencies { [weak self] result in
            guard let self else { return }
            switch result {
            case .success(let currencies):
                Self.logger.info("Currencies loaded successfully. count=\(currencies.count)")
                self.currencyItems = currencies
            case .failure:
                Self.logger.error("Failed to load currencies")
                self.currencyItems = []
                self.state = .error(error: PaymentError.currenciesLoadFailed)
            }
        }
    }

    // MARK: - Public Methods

    func getUICurrency(at index: Int) -> UICurrency? {
        Self.logger.debug("getUICurrency called for index=\(index)")
        guard index < items.count else { return nil }
        return items[index]
    }

    func pay(completion: @escaping (Result<Void, Error>) -> Void) {
        Self.logger.info("Pay flow started")
        state = .paying
        paymentService.pay { [weak self] result in
            guard let self else { return }
            switch result {
            case .success:
                Self.logger.info("Payment service returned success. Clearing cart...")
                self.cartService.clearCart {
                    Self.logger.info("Cart cleared. Posting cartDidChange and setting state .paid")
                    NotificationCenter.default.post(name: .cartDidChange, object: nil)
                    self.state = .paid
                    completion(.success(()))
                }
            case .failure(let error):
                Self.logger.error("Payment service returned failure: \(error.localizedDescription)")
                self.state = .error(error: PaymentError.paymentFailed)
                completion(.failure(error))
            }
        }
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
