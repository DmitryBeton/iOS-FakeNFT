//
//  PaymentViewModelTests.swift
//  FakeNFT
//
//  Created by Дмитрий Чалов on 04.02.2026.
//


import Testing
@testable import FakeNFT
import Foundation

@Suite("PaymentViewModel unit tests")
struct PaymentViewModelTests {

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

    final class ControlledCurrencyService: CurrencyServiceProtocol {
        var result: Result<[Currency], Error> = .success([])
        func fetchCurrencies(completion: @escaping (Result<[Currency], Error>) -> Void) {
            completion(result)
        }
    }

    final class ControlledPaymentService: PaymentServiceProtocol {
        var result: Result<Void, Error> = .success(())
        func pay(completion: @escaping (Result<Void, Error>) -> Void) {
            completion(result)
        }
    }

    @Test("fetch currencies success maps to UI and notifies")
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

        #expect(didUpdate)
        #expect(viewModel.itemsCount == 2)
        let ui0 = try #require(viewModel.getUICurrency(at: 0))
        #expect(ui0.title == "Bitcoin")
        #expect(ui0.name.hasPrefix("BTC"))
    }

    @Test("fetch currencies failure clears items and notifies")
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

        #expect(didUpdate)
        #expect(viewModel.itemsCount == 0)
    }

    @Test("pay success clears cart and posts notification")
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
            #expect(cartService.didClearCart)
            #expect(notificationPosted)
        case .failure:
            Issue.record("Expected success")
        }
    }

    @Test("pay failure propagates error and does not clear cart")
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
            Issue.record("Expected failure")
        case .failure:
            #expect(cartService.didClearCart == false)
        }
    }
}

