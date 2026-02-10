//
//  CurrencyServiceProtocol.swift
//  FakeNFT
//
//  Created by Дмитрий Чалов on 03.02.2026.
//

import Foundation
import OSLog

/// Сервис получения списка доступных валют для оплаты.
///
/// Реализации могут обращаться к сети или использовать локальные/моковые данные.
/// По умолчанию моковая реализация (MockCurrencyService) вызывает completion на главном потоке.
/// Если в реальной реализации поток не гарантируется, вызывающая сторона должна самостоятельно переключаться на нужный поток.
protocol CurrencyServiceProtocol {

    /// Загружает список валют.
    ///
    /// - Parameter completion: Замыкание, вызываемое один раз по завершении операции.
    ///   - result:
    ///     - `.success([Currency])` — массив валют в случае успешной загрузки.
    ///     - `.failure(Error)` — ошибка загрузки/парсинга/сети.
    ///
    /// - Note: Моковая реализация вызывает completion на главном потоке с искусственной задержкой.
    /// - Important: В прод-реализации убедитесь, что вы документируете поток вызова completion,
    ///   либо всегда переключайтесь на нужный поток на стороне клиента.
    func fetchCurrencies(completion: @escaping (Result<[Currency], Error>) -> Void)
}

/// Моковая реализация сервиса валют.
/// Симулирует успешную или неуспешную загрузку с настраиваемой задержкой.
final class MockCurrencyService: CurrencyServiceProtocol {
    enum MockError: Error {
        case failed
    }

    /// Определяет, вернется ли успех или ошибка.
    var shouldSucceed: Bool = true

    /// Задержка перед ответом, секунды.
    var delay: TimeInterval = 0.5

    var stubCurrencies: [Currency] = [
        Currency(
            title: "Shiba_Inu",
            name: "SHIB",
            image: "https://code.s3.yandex.net/Mobile/iOS/Currencies/Shiba_Inu_(SHIB).png",
            id: "0"
        ),
        Currency(
            title: "Cardano",
            name: "ADA",
            image: "https://code.s3.yandex.net/Mobile/iOS/Currencies/Cardano_(ADA).png",
            id: "1"
        )
    ]

    func fetchCurrencies(completion: @escaping (Result<[Currency], Error>) -> Void) {
        DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
            if self.shouldSucceed {
                completion(.success(self.stubCurrencies))
            } else {
                completion(.failure(MockError.failed))
            }
        }
    }
}

final class CurrencyService: CurrencyServiceProtocol {
    private static let logger = Logger(subsystem: "com.fakenft.app", category: "CurrencyService")

    private let networkClient: NetworkClient
    private let callbackQueue = DispatchQueue(label: "com.fakenft.currency.callback", qos: .userInitiated)

    init(networkClient: NetworkClient = DefaultNetworkClient()) {
        self.networkClient = networkClient
    }

    func fetchCurrencies(completion: @escaping (Result<[Currency], Error>) -> Void) {
        Self.logger.info("Fetching currencies from /api/v1/currencies")
        networkClient.send(
            request: CurrencyRequest(),
            type: [Currency].self,
            completionQueue: callbackQueue
        ) { result in
            switch result {
            case .success(let currencies):
                Self.logger.info("Currencies fetched successfully. count=\(currencies.count)")
                DispatchQueue.main.async {
                    completion(.success(currencies))
                }
            case .failure(let error):
                Self.logger.error("Failed to fetch currencies: \(String(describing: error), privacy: .public)")
                DispatchQueue.main.async {
                    completion(.failure(error))
                }
            }
        }
    }
}
