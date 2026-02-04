//
//  PaymentViewModelTests.swift
//  FakeNFT
//
//  Created by Дмитрий Чалов on 04.02.2026.
//
//  Описание:
//  Набор unit-тестов для PaymentViewModel, покрывающий ключевую бизнес-логику:
//  - загрузка списка валют (успех/ошибка) и трансформация в UI-модели;
//  - процесс оплаты (успех/ошибка), очистка корзины и публикация уведомления о её изменении.
//
//  Подход:
//  - Используем контролируемые моки сервисов (ControlledCurrencyService, ControlledPaymentService)
//    и шпион (SpyCartService), чтобы детерминированно управлять результатами и наблюдать эффекты.
//  - Тесты изолированы от UI, проверяют только бизнес-логику и побочные эффекты (notification).
//  - Коллбеки onItemsUpdated вызываются синхронно в моках, что ускоряет и упрощает тесты.
//

import Testing
@testable import FakeNFT
import Foundation

@Suite("PaymentViewModel unit tests")
struct PaymentViewModelTests {

    // MARK: - Test Doubles

    /// Шпион CartService, чтобы проверить факт очистки корзины при успешной оплате.
    final class SpyCartService: CartServiceProtocol {
        var didClearCart = false
        var items: [CartItem] = []

        func fetchCartItems(completion: @escaping (Result<[CartItem], Error>) -> Void) {
            completion(.success(items))
        }

        func deleteCartItem(id: String, completion: @escaping () -> Void) { completion() }
        func saveCartItems(_ items: [CartItem], completion: @escaping () -> Void) { completion() }

        func clearCart(completion: @escaping () -> Void) {
            didClearCart = true
            completion()
        }
    }

    /// Контролируемый мок CurrencyService, позволяющий задать успех/ошибку и вернуть нужный набор валют.
    final class ControlledCurrencyService: CurrencyServiceProtocol {
        var result: Result<[Currency], Error> = .success([])
        func fetchCurrencies(completion: @escaping (Result<[Currency], Error>) -> Void) {
            completion(result)
        }
    }

    /// Контролируемый мок PaymentService, позволяющий задать успех/ошибку оплаты.
    final class ControlledPaymentService: PaymentServiceProtocol {
        var result: Result<Void, Error> = .success(())
        func pay(completion: @escaping (Result<Void, Error>) -> Void) {
            completion(result)
        }
    }

    // MARK: - Tests

    @Test("fetch currencies success maps to UI and notifies")
    /// Проверяет, что при успешной загрузке валют:
    /// - вызывается onItemsUpdated,
    /// - количество UI-элементов совпадает с числом валют,
    /// - данные корректно маппятся в UICurrency (title/name/logo).
    func testFetchCurrenciesSuccess() async throws {
        let currencyService = ControlledCurrencyService()
        currencyService.result = .success([
            Currency(title: "Bitcoin", name: "BTC", logo: "Bitcoin"),
            Currency(title: "Ethereum", name: "ETH", logo: "Ethereum")
        ])
        let paymentService = ControlledPaymentService()
        let cartService = SpyCartService()

        let viewModel = PaymentViewModel(paymentService: paymentService,
                                         currencyService: currencyService,
                                         cartService: cartService)

        var didUpdate = false
        viewModel.onItemsUpdated = { didUpdate = true }

        viewModel.loadItems()

        #expect(didUpdate, "onItemsUpdated должен вызываться при обновлении items")
        #expect(viewModel.itemsCount == 2, "Ожидаем ровно 2 валюты из мока")
        let ui0 = try #require(viewModel.getUICurrency(at: 0), "UI-модель по индексу 0 должна существовать")
        #expect(ui0.title == "Bitcoin", "Неверный title после маппинга")
        #expect(ui0.name.hasPrefix("BTC"), "Ожидаем, что name начинается с кода валюты")
    }

    @Test("fetch currencies failure clears items and notifies")
    /// Проверяет, что при ошибке загрузки валют:
    /// - вызывается onItemsUpdated,
    /// - список UI-элементов становится пустым.
    func testFetchCurrenciesFailure() async throws {
        let currencyService = ControlledCurrencyService()
        enum E: Error { case fail }
        currencyService.result = .failure(E.fail)

        let paymentService = ControlledPaymentService()
        let cartService = SpyCartService()

        let viewModel = PaymentViewModel(paymentService: paymentService,
                                         currencyService: currencyService,
                                         cartService: cartService)

        var didUpdate = false
        viewModel.onItemsUpdated = { didUpdate = true }

        viewModel.loadItems()

        #expect(didUpdate, "onItemsUpdated должен вызываться при ошибке загрузки")
        #expect(viewModel.itemsCount == 0, "При ошибке загрузки список валют должен быть пустым")
    }

    @Test("pay success clears cart and posts notification")
    /// Проверяет, что при успешной оплате:
    /// - вызывается CartService.clearCart,
    /// - публикуется уведомление Notification.Name.cartDidChange,
    /// - completion завершится с успехом.
    func testPaySuccess() async throws {
        let currencyService = ControlledCurrencyService()
        let paymentService = ControlledPaymentService()
        paymentService.result = .success(())
        let cartService = SpyCartService()

        let viewModel = PaymentViewModel(paymentService: paymentService,
                                         currencyService: currencyService,
                                         cartService: cartService)

        var notificationPosted = false
        let obs = NotificationCenter.default.addObserver(forName: .cartDidChange, object: nil, queue: .main) { _ in
            notificationPosted = true
        }
        defer { NotificationCenter.default.removeObserver(obs) }

        let result = await withCheckedContinuation { (cont: CheckedContinuation<Result<Void, Error>, Never>) in
            viewModel.pay { cont.resume(returning: $0) }
        }

        switch result {
        case .success:
            #expect(cartService.didClearCart, "Корзина должна очищаться при успешной оплате")
            #expect(notificationPosted, "Должно публиковаться уведомление .cartDidChange")
        case .failure:
            Issue.record("Ожидался успех оплаты, но пришла ошибка")
        }
    }

    @Test("pay failure propagates error and does not clear cart")
    /// Проверяет, что при ошибке оплаты:
    /// - completion возвращает ошибку,
    /// - корзина НЕ очищается,
    /// - уведомление не обязательно публикуется.
    func testPayFailure() async throws {
        enum E: Error { case fail }
        let currencyService = ControlledCurrencyService()
        let paymentService = ControlledPaymentService()
        paymentService.result = .failure(E.fail)
        let cartService = SpyCartService()

        let viewModel = PaymentViewModel(paymentService: paymentService,
                                         currencyService: currencyService,
                                         cartService: cartService)

        let result = await withCheckedContinuation { (cont: CheckedContinuation<Result<Void, Error>, Never>) in
            viewModel.pay { cont.resume(returning: $0) }
        }

        switch result {
        case .success:
            Issue.record("Ожидалась ошибка оплаты, но пришел успех")
        case .failure:
            #expect(cartService.didClearCart == false, "Корзина не должна очищаться при ошибке оплаты")
        }
    }
}

