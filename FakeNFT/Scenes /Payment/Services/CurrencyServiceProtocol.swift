//
//  CurrencyServiceProtocol.swift
//  FakeNFT
//
//  Created by Дмитрий Чалов on 03.02.2026.
//

import Foundation

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
    var shouldSucceed: Bool = false

    /// Задержка перед ответом, секунды.
    var delay: TimeInterval = 0.5

    var stubCurrencies: [Currency] = [
        Currency(title: "Bitcoin", name: "BTC", logo: "Bitcoin"),
        Currency(title: "Dogecoin", name: "DOGE", logo: "Dogecoin"),
        Currency(title: "Tether", name: "USDT", logo: "Tether"),
        Currency(title: "Apecoin", name: "APE", logo: "Apecoin"),
        Currency(title: "Solana", name: "SOL", logo: "Solana"),
        Currency(title: "Ethereum", name: "ETH", logo: "Ethereum"),
        Currency(title: "Cardano", name: "ADA", logo: "Cardano"),
        Currency(title: "Shiba Inu", name: "SHIB", logo: "ShibaInu")
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
