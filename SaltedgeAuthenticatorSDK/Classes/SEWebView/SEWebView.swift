//
//  SEWebView.swift
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

import WebKit

public protocol SEWebViewDelegate: NSObjectProtocol {
    func webView(_ webView: WKWebView, didReceiveCallback url: URL, accessToken: AccessToken)
    func webView(_ webView: WKWebView, didReceiveCallbackWithError error: String?)
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!)
}

public class SEWebView: WKWebView {
    public weak var delegate: SEWebViewDelegate?

    public init(frame: CGRect) {
        super.init(frame: frame, configuration: WKWebViewConfiguration())
        self.navigationDelegate = self
    }

    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.navigationDelegate = self
    }
}

// MARK: - WKNavigationDelegate
extension SEWebView: WKNavigationDelegate {
    public func webView(_ webView: WKWebView,
                        decidePolicyFor navigationAction: WKNavigationAction,
                        decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        if let url = navigationAction.request.url, SENetConstants.hasRedirectUrl(url.absoluteString) {
            if let accessToken = url.queryItem(for: SENetKeys.accessToken) {
                self.delegate?.webView(self, didReceiveCallback: url, accessToken: accessToken)
            } else {
                self.delegate?.webView(
                    self, didReceiveCallbackWithError: url.queryItem(for: SENetKeys.errorClass) ?? "Something went wrong."
                )
            }

            decisionHandler(.cancel)
        } else {
            decisionHandler(.allow)
        }
    }

    public func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        delegate?.webView(webView, didFinish: navigation)
    }

    public func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
        delegate?.webView(webView, didReceiveCallbackWithError: error.localizedDescription)
    }

    public func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: Error) {
        delegate?.webView(webView, didReceiveCallbackWithError: error.localizedDescription)
    }
}
