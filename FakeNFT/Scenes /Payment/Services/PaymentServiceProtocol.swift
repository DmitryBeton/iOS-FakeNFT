//
//  PaymentServiceProtocol.swift
//  FakeNFT
//
//  Created by Дмитрий Чалов on 03.02.2026.
//

import Foundation
import OSLog

/// Протокол сервиса оплаты.
///
/// Инкапсулирует вызов API/логики оплаты и сообщает результат через completion.
/// Конкретная реализация может работать с сетью, локальными моками или SDK.
///
/// - Threading: Рекомендуется вызывать completion на главном потоке,
/// так как результат оплаты обычно приводит к обновлению UI.
protocol PaymentServiceProtocol {
    /// Выполняет оплату.
    ///
    /// - Parameter completion: Замыкание, вызываемое один раз по завершении оплаты.
    ///   - result:
    ///     - `.success(())` — оплата прошла успешно.
    ///     - `.failure(Error)` — ошибка оплаты (например, сетевая/таймаут/отмена/валидация).
    ///
    /// - Important: Если реализация не гарантирует главный поток, вызывающая сторона
    /// должна самостоятельно переключаться на нужный поток.
    func pay(currencyID: String, completion: @escaping (Result<Void, Error>) -> Void)
}

/// Моковая реализация сервиса оплаты.
/// Позволяет симулировать успех/ошибку с настраиваемой задержкой.
final class MockPaymentService: PaymentServiceProtocol {
    enum MockError: Error {
        case failed
    }

    /// Флаг успешного результата.
    var shouldSucceed: Bool = true

    /// Искуственная задержка ответа, в секундах.
    var delay: TimeInterval = 1.0

    func pay(currencyID _: String, completion: @escaping (Result<Void, Error>) -> Void) {
        DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
            if self.shouldSucceed {
                completion(.success(()))
            } else {
                completion(.failure(MockError.failed))
            }
        }
    }
}

enum PaymentServiceError: Error {
    case paymentNotAllowed
}

final class PaymentService: PaymentServiceProtocol {
    private static let logger = Logger(subsystem: "com.fakenft.app", category: "PaymentService")

    private let networkClient: NetworkClient
    private let callbackQueue = DispatchQueue(label: "com.fakenft.payment.callback", qos: .userInitiated)

    init(networkClient: NetworkClient = DefaultNetworkClient()) {
        self.networkClient = networkClient
    }

    func pay(currencyID: String, completion: @escaping (Result<Void, Error>) -> Void) {
        let traceID = UUID().uuidString
        Self.logger.info("[\(traceID, privacy: .public)] Start payment flow. currencyID=\(currencyID, privacy: .public)")

        bindCurrency(currencyID: currencyID, traceID: traceID) { [weak self] result in
            guard let self else { return }
            switch result {
            case .success:
                self.completeOrder(traceID: traceID, completion: completion)
            case .failure(let error):
                DispatchQueue.main.async {
                    completion(.failure(error))
                }
            }
        }
    }
}

private extension PaymentService {
    func bindCurrency(currencyID: String, traceID: String, completion: @escaping (Result<Void, Error>) -> Void) {
        Self.logger.debug("[\(traceID, privacy: .public)] Binding currency to order")
        networkClient.send(
            request: SetOrderPaymentCurrencyRequest(currencyID: currencyID),
            type: PaymentCurrencyBindResponse.self,
            completionQueue: callbackQueue
        ) { result in
            switch result {
            case .success(let response):
                Self.logger.info("[\(traceID, privacy: .public)] Currency bind response. success=\(response.success), orderID=\(response.orderId, privacy: .public), id=\(response.id, privacy: .public)")
                if response.success {
                    completion(.success(()))
                } else {
                    completion(.failure(PaymentServiceError.paymentNotAllowed))
                }
            case .failure(let error):
                Self.logger.error("[\(traceID, privacy: .public)] Currency bind failed: \(String(describing: error), privacy: .public)")
                completion(.failure(error))
            }
        }
    }

    func completeOrder(traceID: String, completion: @escaping (Result<Void, Error>) -> Void) {
        Self.logger.debug("[\(traceID, privacy: .public)] Loading order IDs before final payment request")
        networkClient.send(
            request: CartOrderRequest(),
            type: CartOrderResponse.self,
            completionQueue: callbackQueue
        ) { [weak self] result in
            guard let self else { return }

            switch result {
            case .success(let order):
                Self.logger.info("[\(traceID, privacy: .public)] Order fetched. nftsCount=\(order.nfts.count), orderID=\(order.id, privacy: .public)")
                self.sendCompleteOrderRequest(nftIDs: order.nfts, traceID: traceID, completion: completion)
            case .failure(let error):
                Self.logger.error("[\(traceID, privacy: .public)] Failed to load order before payment: \(String(describing: error), privacy: .public)")
                DispatchQueue.main.async {
                    completion(.failure(error))
                }
            }
        }
    }

    func sendCompleteOrderRequest(nftIDs: [String], traceID: String, completion: @escaping (Result<Void, Error>) -> Void) {
        Self.logger.debug("[\(traceID, privacy: .public)] Sending final payment request with repeated nfts fields. idsCount=\(nftIDs.count)")
        networkClient.send(
            request: CompleteOrderRequest(nftIDs: nftIDs),
            type: CartOrderResponse.self,
            completionQueue: callbackQueue
        ) { [weak self] result in
            guard let self else { return }

            switch result {
            case .success(let response):
                Self.logger.info("[\(traceID, privacy: .public)] Final payment request succeeded. responseOrderID=\(response.id, privacy: .public)")
                self.clearOrderAfterPayment(traceID: traceID, completion: completion)
            case .failure(let error):
                Self.logger.error("[\(traceID, privacy: .public)] Final payment request failed: \(String(describing: error), privacy: .public)")
                DispatchQueue.main.async {
                    completion(.failure(error))
                }
            }
        }
    }

    func clearOrderAfterPayment(traceID: String, completion: @escaping (Result<Void, Error>) -> Void) {
        Self.logger.debug("[\(traceID, privacy: .public)] Clearing order after successful payment")
        networkClient.send(
            request: UpdateCartOrderRequest(nftIDs: []),
            type: CartOrderResponse.self,
            completionQueue: callbackQueue
        ) { result in
            switch result {
            case .success:
                Self.logger.info("[\(traceID, privacy: .public)] Order cleared successfully after payment")
                DispatchQueue.main.async {
                    NotificationCenter.default.post(name: .cartDidChange, object: nil)
                    completion(.success(()))
                }
            case .failure(let error):
                Self.logger.error("[\(traceID, privacy: .public)] Order clear failed: \(String(describing: error), privacy: .public)")
                DispatchQueue.main.async {
                    completion(.failure(error))
                }
            }
        }
    }
}
