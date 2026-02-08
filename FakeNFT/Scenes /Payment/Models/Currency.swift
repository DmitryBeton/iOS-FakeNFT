//
//  Currency.swift
//  FakeNFT
//
//  Created by Дмитрий Чалов on 03.02.2026.
//

import Foundation

struct Currency: Codable, Equatable {
    let title: String
    let name: String
    let image: String
    let id: String
}

struct PaymentCurrencyBindResponse: Codable {
    let success: Bool
    let orderId: String
    let id: String
}
