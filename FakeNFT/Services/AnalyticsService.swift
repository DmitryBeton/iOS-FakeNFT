//
//  AnalyticsService.swift
//  FakeNFT
//
//  Created by Дмитрий Чалов on 09.02.2026.
//


import Foundation
import YandexMobileMetrica

protocol AnalyticsReporting {
    func track(_ event: AnalyticsEvent)
}

enum AnalyticsEvent {
    case screenOpened(name: String)
    case buttonTapped(name: String, screen: String)
    case nftPurchased(id: String, price: Decimal)

    var name: String {
        switch self {
        case .screenOpened: return "screen_opened"
        case .buttonTapped: return "button_tapped"
        case .nftPurchased: return "nft_purchased"
        }
    }

    var params: [String: Any] {
        switch self {
        case .screenOpened(let name):
            return ["screen_name": name]
        case .buttonTapped(let name, let screen):
            return ["button_name": name, "screen_name": screen]
        case .nftPurchased(let id, let price):
            return ["nft_id": id, "price": "\(price)"]
        }
    }
}

final class AnalyticsService: AnalyticsReporting {
    static let shared = AnalyticsService()
    private init() {}

    static func activate(apiKey: String) {
        guard let config = YMMYandexMetricaConfiguration(apiKey: apiKey) else { return }
        YMMYandexMetrica.activate(with: config)
    }

    func track(_ event: AnalyticsEvent) {
        YMMYandexMetrica.reportEvent(event.name, parameters: event.params) { error in
            NSLog("Analytics report failed: \(error.localizedDescription)")
        }
    }
}
