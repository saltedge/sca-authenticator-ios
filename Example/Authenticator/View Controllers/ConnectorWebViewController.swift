//
//  ConnectorWebViewController.swift
//  This file is part of the Salt Edge Authenticator distribution
//  (https://github.com/saltedge/sca-authenticator-ios)
//  Copyright © 2019 Salt Edge Inc.
//
//  This program is free software: you can redistribute it and/or modify
//  it under the terms of the GNU General Public License as published by
//  the Free Software Foundation, version 3 or later.
//
//  This program is distributed in the hope that it will be useful, but
//  WITHOUT ANY WARRANTY; without even the implied warranty of
//  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU
//  General Public License for more details.
//
//  You should have received a copy of the GNU General Public License
//  along with this program. If not, see <http://www.gnu.org/licenses/>.
//
//  For the additional permissions granted for Salt Edge Authenticator
//  under Section 7 of the GNU General Public License see THIRD_PARTY_NOTICES.md
//

import UIKit
import WebKit
import SEAuthenticator

protocol ConnectorWebViewControllerDelegate: WKWebViewControllerDelegate {
    func connectorConfirmed(url: URL, accessToken: AccessToken)
    func showError(_ error: String)
}

final class ConnectorWebViewController: UIViewController {
    weak var delegate: ConnectorWebViewControllerDelegate?

    private var webView: SEWebView
    private let loadingIndicator = LoadingIndicator()

    init() {
        webView = SEWebView(frame: .zero)
        super.init(nibName: nil, bundle: .authenticator_main)
    }

    override func loadView() {
        super.loadView()
        webView.delegate = self
        view = webView
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        layout()
        loadingIndicator.start()
    }

    func startLoading(with url: String) {
        guard let url = URL(string: url) else { return }

        let request = URLRequest(url: url)
        webView.load(request)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: - Layout
extension ConnectorWebViewController: Layoutable {
    func layout() {
        view.addSubview(loadingIndicator)

        loadingIndicator.center(in: view)
        loadingIndicator.size(AppLayout.loadingIndicatorSize)
    }
}

extension ConnectorWebViewController: SEWebViewDelegate {
    func webView(_ webView: WKWebView, didReceiveCallback url: URL, accessToken: AccessToken) {
        loadingIndicator.stop()
        delegate?.connectorConfirmed(url: url, accessToken: accessToken)
    }

    func webView(_ webView: WKWebView, didReceiveCallbackWithError error: String?) {
        loadingIndicator.stop()
        if let error = error { delegate?.showError(error) }
    }

    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        loadingIndicator.stop()
    }
}
