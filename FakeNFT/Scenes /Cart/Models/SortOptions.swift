//
//  SortOptions.swift
//  FakeNFT
//
//  Created by Дмитрий Чалов on 24.01.2026.
//

enum SortOption: String, CaseIterable {
    case price
    case rating
    case name
    
    var localizedWord: String {
        switch self {
        case .price: Localization.Cart.filterByPrice.localized
        case .rating: Localization.Cart.filterByRating.localized
        case .name: Localization.Cart.filterByTitle.localized
        }
    }
}
