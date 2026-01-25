//
//  SortOptionStore.swift
//  FakeNFT
//
//  Created by Дмитрий Чалов on 25.01.2026.
//

import Foundation

protocol SortOptionStore {
    func load() -> SortOption
    func save(_ option: SortOption)
}

final class UserDefaultsSortOptionStore: SortOptionStore {
    private let defaults: UserDefaults
    private let key: String
    
    init(defaults: UserDefaults = .standard , key: String = "app.sortOption") {
        self.defaults = defaults
        self.key = key
    }
    
    func load() -> SortOption {
        if let raw = defaults.string(forKey: key),
           let option = SortOption(rawValue: raw) {
            return option
        }
        return .name
    }
    
    func save(_ option: SortOption) {
        defaults.set(option.rawValue, forKey: key)
    }
}
