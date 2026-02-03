//
//  PaymentServiceProtocol.swift
//  FakeNFT
//
//  Created by Дмитрий Чалов on 03.02.2026.
//

import Foundation

protocol PaymentServiceProtocol {
    func pay(completion: @escaping (Result<Void, Error>) -> Void)
}

final class MockPaymentService: PaymentServiceProtocol {
    enum MockError: Error {
        case failed
    }
    
    var shouldSucceed: Bool = true
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
