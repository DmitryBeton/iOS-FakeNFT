//
//  PaymentServiceProtocol.swift
//  FakeNFT
//
//  Created by Дмитрий Чалов on 03.02.2026.
//

import Foundation

/// Протокол сервиса оплаты.
///
/// Инкапсулирует вызов API/логики оплаты и сообщает результат через completion.
/// Конкретная реализация может работать с сетью, локальными моками или SDK.
//
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
    func pay(completion: @escaping (Result<Void, Error>) -> Void)
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
    
    func pay(completion: @escaping (Result<Void, Error>) -> Void) {
        DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
            if self.shouldSucceed {
                completion(.success(()))
            } else {
                completion(.failure(MockError.failed))
            }
        }
    }
}
