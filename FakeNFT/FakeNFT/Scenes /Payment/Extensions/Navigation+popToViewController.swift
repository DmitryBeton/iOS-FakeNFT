//
//  Navigation+popToViewController.swift
//  FakeNFT
//
//  Created by Дмитрий Чалов on 04.02.2026.
//

import UIKit

extension UINavigationController {
    func popToViewController<T: UIViewController>(ofType type: T.Type, animated: Bool) {
        if let target = viewControllers.first(where: { $0 is T }) {
            popToViewController(target, animated: animated)
        }
    }
}
