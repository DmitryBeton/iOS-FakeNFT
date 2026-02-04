//
//  AgreementWebViewController.swift
//  FakeNFT
//
//  Created by Дмитрий Чалов on 03.02.2026.
//

import UIKit
import WebKit

final class AgreementWebViewController: UIViewController {
    // MARK: - Properties
    private let urlString: String
    private var webView: WKWebView
    private var estimatedProgressObservation: NSKeyValueObservation?

    // MARK: - UI Elements
    private lazy var progressView: UIProgressView = {
        let progressView = UIProgressView()
        progressView.translatesAutoresizingMaskIntoConstraints = false
        progressView.progressTintColor = UIColor(resource: .nftBlack)
        progressView.trackTintColor = UIColor(resource: .nftLightGray)
        progressView.progress = 0.0
        return progressView
    }()

    // MARK: - Initialization
    init(urlString: String) {
        self.urlString = urlString
        webView = WKWebView()
        super.init(nibName: nil, bundle: nil)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        nil
    }

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupConstraints()
        loadWebPage()
        setupObservers()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        estimatedProgressObservation = nil
    }

    deinit {
        estimatedProgressObservation?.invalidate()
    }

    // MARK: - Private Methods
    private func setupUI() {
        view.backgroundColor = UIColor(resource: .nftWhite)

        webView.translatesAutoresizingMaskIntoConstraints = false
        webView.navigationDelegate = self

        view.addSubview(progressView)
        view.addSubview(webView)
    }

    private func setupConstraints() {
        NSLayoutConstraint.activate([
            progressView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            progressView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            progressView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            progressView.heightAnchor.constraint(equalToConstant: 2),

            webView.topAnchor.constraint(equalTo: progressView.bottomAnchor),
            webView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            webView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            webView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }

    private func loadWebPage() {
        guard let url = URL(string: urlString) else {
            showErrorAlert()
            return
        }

        let request = URLRequest(url: url)
        webView.load(request)
    }

    private func setupObservers() {
        estimatedProgressObservation = webView.observe(
            \.estimatedProgress,
             options: .new
        ) { [weak self] _, change in
            guard let self = self,
                  let newValue = change.newValue else { return }

            self.updateProgress(Float(newValue))
        }
    }

    private func updateProgress(_ newValue: Float) {
        progressView.setProgress(newValue, animated: true)

        let shouldHideProgress = shouldHideProgress(for: newValue)
        progressView.isHidden = shouldHideProgress

        if shouldHideProgress {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                self.progressView.progress = 0.0
            }
        }
    }

    private func shouldHideProgress(for value: Float) -> Bool {
        return abs(value - 1.0) <= 0.001
    }

    private func showErrorAlert() {
        let alert = UIAlertController(
            title: "Ошибка",
            message: "Не удалось загрузить страницу",
            preferredStyle: .alert
        )

        alert.addAction(UIAlertAction(title: "OK", style: .default) { [weak self] _ in
            self?.navigationController?.popViewController(animated: true)
        })

        present(alert, animated: true)
    }
}

// MARK: - WKNavigationDelegate
extension AgreementWebViewController: WKNavigationDelegate {
    func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
        progressView.isHidden = false
        progressView.progress = 0.1
    }

    func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
        progressView.isHidden = true
        showErrorAlert()
    }

    func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: Error) {
        progressView.isHidden = true
        showErrorAlert()
    }
}
