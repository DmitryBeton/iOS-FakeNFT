//
//  PaymentViewModel.swift
//  FakeNFT
//
//  Created by Дмитрий Чалов on 02.02.2026.
//

import UIKit
import OSLog

protocol LoadCurrenciesUseCaseProtocol {
    func execute(completion: @escaping (Result<[Currency], Error>) -> Void)
}

final class LoadCurrenciesUseCase: LoadCurrenciesUseCaseProtocol {
    private let currencyService: CurrencyServiceProtocol

    init(currencyService: CurrencyServiceProtocol) {
        self.currencyService = currencyService
    }

    func execute(completion: @escaping (Result<[Currency], Error>) -> Void) {
        currencyService.fetchCurrencies(completion: completion)
    }
}

protocol PayOrderUseCaseProtocol {
    func execute(currencyID: String, completion: @escaping (Result<Void, Error>) -> Void)
}

final class PayOrderUseCase: PayOrderUseCaseProtocol {
    private let paymentService: PaymentServiceProtocol

    init(paymentService: PaymentServiceProtocol) {
        self.paymentService = paymentService
    }

    func execute(currencyID: String, completion: @escaping (Result<Void, Error>) -> Void) {
        paymentService.pay(currencyID: currencyID, completion: completion)
    }
}

enum PaymentErrorContext {
    case currencyLoad
    case payment
}

protocol PaymentErrorMapping {
    func map(_ error: Error, context: PaymentErrorContext) -> PaymentError
}

final class PaymentErrorMapper: PaymentErrorMapping {
    func map(_ error: Error, context: PaymentErrorContext) -> PaymentError {
        if let networkError = error as? NetworkClientError {
            switch networkError {
            case .httpStatusCode(let code):
                return .server(code: code)
            case .urlRequestError:
                return .networkOffline
            case .urlSessionError, .parsingError:
                return context == .currencyLoad ? .currenciesLoadFailed : .paymentFailed
            }
        }

        if context == .payment, error is PaymentServiceError {
            return .paymentFailed
        }

        return .unknown(underlying: error)
    }
}

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
    case currencyNotSelected
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

    /// Выбирает валюту по индексу.
    func selectCurrency(at index: Int)

    /// Сбрасывает выбранную валюту.
    func clearSelectedCurrency()
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
    private var selectedCurrencyID: String?

    private let loadCurrenciesUseCase: LoadCurrenciesUseCaseProtocol
    private let payOrderUseCase: PayOrderUseCaseProtocol
    private let errorMapper: PaymentErrorMapping

    // MARK: - Initialization
    init(
        loadCurrenciesUseCase: LoadCurrenciesUseCaseProtocol,
        payOrderUseCase: PayOrderUseCaseProtocol,
        errorMapper: PaymentErrorMapping = PaymentErrorMapper()
    ) {
        self.loadCurrenciesUseCase = loadCurrenciesUseCase
        self.payOrderUseCase = payOrderUseCase
        self.errorMapper = errorMapper
    }

    convenience init(
        paymentService: PaymentServiceProtocol = PaymentService(),
        currencyService: CurrencyServiceProtocol = CurrencyService()
    ) {
        self.init(
            loadCurrenciesUseCase: LoadCurrenciesUseCase(currencyService: currencyService),
            payOrderUseCase: PayOrderUseCase(paymentService: paymentService),
            errorMapper: PaymentErrorMapper()
        )
    }

    func loadItems() {
        Self.logger.info("Loading currencies started")
        state = .loadingCurrencies
        loadCurrenciesUseCase.execute { [weak self] result in
            guard let self else { return }
            switch result {
            case .success(let currencies):
                Self.logger.info("Currencies loaded successfully. count=\(currencies.count)")
                self.currencyItems = currencies
            case .failure(let error):
                Self.logger.error("Failed to load currencies: \(error.localizedDescription)")
                self.currencyItems = []
                self.state = .error(error: self.errorMapper.map(error, context: .currencyLoad))
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
        guard let selectedCurrencyID else {
            Self.logger.error("Pay requested without selected currency")
            state = .error(error: .currencyNotSelected)
            completion(.failure(PaymentError.currencyNotSelected))
            return
        }

        Self.logger.info("Pay flow started")
        state = .paying
        payOrderUseCase.execute(currencyID: selectedCurrencyID) { [weak self] result in
            guard let self else { return }
            switch result {
            case .success:
                Self.logger.info("Payment service returned success")
                self.state = .paid
                completion(.success(()))
            case .failure(let error):
                Self.logger.error("Payment service returned failure: \(error.localizedDescription)")
                self.state = .error(error: self.errorMapper.map(error, context: .payment))
                completion(.failure(error))
            }
        }
    }

    func selectCurrency(at index: Int) {
        guard index < items.count else {
            selectedCurrencyID = nil
            return
        }
        selectedCurrencyID = items[index].id
        let selectedID = selectedCurrencyID ?? ""
        Self.logger.info("Selected currency id=\(selectedID, privacy: .public)")
    }

    func clearSelectedCurrency() {
        selectedCurrencyID = nil
        Self.logger.debug("Cleared selected currency")
    }

    // MARK: - Mapping
    private func mapToUI(_ currency: Currency) -> UICurrency {
        return UICurrency(
            id: currency.id,
            title: currency.title,
            name: currency.name,
            imageURL: URL(string: currency.image)
        )
    }
}
