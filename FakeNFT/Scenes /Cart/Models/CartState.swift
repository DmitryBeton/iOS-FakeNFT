//
//  CartState.swift
//  FakeNFT
//
//  Created by Дмитрий Чалов on 24.01.2026.
//

enum CartState {
    case loading
    case content
    case empty(message: String = Localization.Cart.emptyStateMessage.localized)
    case error(message: String)
}
