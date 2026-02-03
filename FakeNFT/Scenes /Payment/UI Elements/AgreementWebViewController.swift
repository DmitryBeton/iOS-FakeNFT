//
//  AgreementWebViewController.swift
//  FakeNFT
//
//  Created by Дмитрий Чалов on 03.02.2026.
//

import UIKit
import WebKit

final class AgreementWebViewController: UIViewController {
    private let urlString: String
    private var webView: WKWebView!

    init(urlString: String) {
        self.urlString = urlString
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        nil
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor(resource: .nftWhite)
        webView = WKWebView(frame: .zero)
        view.addSubview(webView)
        webView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            webView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            webView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            webView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            webView.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])
        if let url = URL(string: urlString) {
            webView.load(URLRequest(url: url))
        }
    }
}
