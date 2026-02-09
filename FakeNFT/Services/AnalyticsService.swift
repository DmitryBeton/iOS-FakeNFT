//
//  AnalyticsService.swift
//  FakeNFT
//
//  Created by Дмитрий Чалов on 09.02.2026.
//

import Foundation
import AppMetricaCore

protocol AnalyticsReporting {
    func track(_ event: AnalyticsEvent)
}

enum AnalyticsEvent {
    case screenOpened(name: String)
    case buttonTapped(name: String, screen: String)
    case currencySelected(id: String, name: String)
    case cartItemRemoved(id: String, source: String)
    case checkoutStarted(itemCount: Int, totalPrice: Double)
    case purchaseCompleted(itemCount: Int, totalPrice: Double, currencyID: String?)
    case purchaseFailed(reason: String)

    var name: String {
        switch self {
        case .screenOpened: return "screen_opened"
        case .buttonTapped: return "button_tapped"
        case .currencySelected: return "currency_selected"
        case .cartItemRemoved: return "cart_item_removed"
        case .checkoutStarted: return "checkout_started"
        case .purchaseCompleted: return "purchase_completed"
        case .purchaseFailed: return "purchase_failed"
        }
    }

    var params: [String: Any] {
        switch self {
        case .screenOpened(let name):
            return ["screen_name": name]
        case .buttonTapped(let name, let screen):
            return ["button_name": name, "screen_name": screen]
        case .currencySelected(let id, let name):
            return ["currency_id": id, "currency_name": name]
        case .cartItemRemoved(let id, let source):
            return ["nft_id": id, "source": source]
        case .checkoutStarted(let itemCount, let totalPrice):
            return ["item_count": itemCount, "total_price": roundedPrice(totalPrice)]
        case .purchaseCompleted(let itemCount, let totalPrice, let currencyID):
            var params: [String: Any] = [
                "item_count": itemCount,
                "total_price": roundedPrice(totalPrice)
            ]
            if let currencyID {
                params["currency_id"] = currencyID
            }
            return params
        case .purchaseFailed(let reason):
            return ["reason": reason]
        }
    }

    private func roundedPrice(_ value: Double) -> Double {
        (value * 100).rounded() / 100
    }
}

final class AnalyticsService: AnalyticsReporting {
    static let shared = AnalyticsService()
    private static let apiKey = "40f94686-81e7-470e-9d57-59b7967a1a70"
    private static var isActivated = false
    private init() {}

    static func activate() {
        guard !isActivated else { return }
        guard let config = AppMetricaConfiguration(apiKey: self.apiKey) else { return }
        AppMetrica.activate(with: config)
        isActivated = true
    }

    func track(_ event: AnalyticsEvent) {
        Self.activate()
        AppMetrica.reportEvent(name: event.name, parameters: event.params) { error in
            NSLog("Analytics report failed: \(error.localizedDescription)")
        }
    }
}
