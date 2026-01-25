//
//  CartItem.swift
//  FakeNFT
//
//  Created by Дмитрий Чалов on 25.01.2026.
//

struct CartItem: Codable, Equatable {
    let id: String
    let name: String
    let images: [String]
    let rating: Int
    let price: Double
}
