//
//  CurrencyServiceProtocol.swift
//  FakeNFT
//
//  Created by Дмитрий Чалов on 03.02.2026.
//

import Foundation

protocol CurrencyServiceProtocol {
    func fetchCurrencies(completion: @escaping (Result<[Currency], Error>) -> Void)
}

final class MockCurrencyService: CurrencyServiceProtocol {
    enum MockError: Error {
        case failed
    }
    
    var shouldSucceed: Bool = true
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
