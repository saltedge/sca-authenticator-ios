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
}

final class ConnectorWebViewController: WKWebViewController {
    func webView(_ webView: WKWebView,
                 decidePolicyFor navigationAction: WKNavigationAction,
                 decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        guard let url = navigationAction.request.url else {
            decisionHandler(.allow)
            return
        }

        decisionHandler(shouldAllowToHandleURL(url) ? .allow : .cancel)
    }

    private func callDelegate(url: URL, accessToken: AccessToken) {
        (delegate as? ConnectorWebViewControllerDelegate)?.connectorConfirmed(url: url, accessToken: accessToken)
    }

    private func dismiss(with error: String?) {
        close()
        delegate?.showError(error ?? l10n(.connectionFailed))
    }

    private func shouldAllowToHandleURL(_ url: URL) -> Bool {
        return SEConnectHelper.skipOrHandleRedirect(
            url: url,
            success: { accessToken in
                self.callDelegate(url: url, accessToken: accessToken)
            },
            failure: { error in
                print(error)
            }
        )
    }
}
