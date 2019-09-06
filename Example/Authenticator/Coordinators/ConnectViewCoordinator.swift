//
//  ConnectViewCoordinator.swift
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
import SEAuthenticator

final class ConnectViewCoordinator: Coordinator {
    private let rootViewController: UIViewController

    private let qrCodeViewController = QRCodeViewController()
    private lazy var webViewController = ConnectorWebViewController()
    private var connectViewController = ConnectViewController()
    private var connection: Connection?
    private let connectionType: ConnectionType
    private let configurationUrl: String?

    init(rootViewController: UIViewController,
         connectionType: ConnectionType,
         configurationUrl: String? = nil,
         connection: Connection? = nil) {
        self.configurationUrl = configurationUrl
        self.rootViewController = rootViewController
        self.connection = connection
        self.connectionType = connectionType
    }

    func start() {
        switch connectionType {
        case .reconnect: loadUrl()
        case .connect: showQrCodeViewController()
        case .deepLink: connectFrom(urlString: configurationUrl)
        }

        rootViewController.present(
            UINavigationController(rootViewController: connectViewController),
            animated: true
        )
    }

    func stop() {}

    private func connectFrom(urlString: String?) {
        guard let link = urlString, let url = URL(string: link) else { return }

        showWebViewController()

        ConnectionsInteractor.getConnectUrl(
            from: url,
            success: { [weak self]  connection, connectUrl in
                guard let strongSelf = self else { return }

                strongSelf.connection = connection
                strongSelf.startWebViewLoading(with: connectUrl)
            },
            failure: { error in
                self.connectViewController.dismiss(animated: true)
                print(error)
            }
        )
    }

    private func showQrCodeViewController() {
        qrCodeViewController.metadataReceived = { vc, qrMetadata in
            vc.remove()
            self.showWebViewController()

            guard ReachabilityManager.shared.isReachable else {
                self.connectViewController.showInfoAlert(
                    withTitle: l10n(.noInternetConnection),
                    message: l10n(.pleaseTryAgain),
                    actionTitle: l10n(.ok),
                    completion: {
                        self.connectViewController.dismiss(animated: true)
                    }
                )
                return
            }

            guard let url = URL(string: qrMetadata),
                let configurationUrl = SEConnectHelper.сonfiguration(from: url)
                else { self.connectViewController.dismiss(animated: true); return }

            ConnectionsInteractor.getConnectUrl(
                from: configurationUrl,
                success: { [weak self]  connection, connectUrl in
                    guard let strongSelf = self else { return }

                    strongSelf.connection = connection
                    strongSelf.webViewController.startLoading(with: connectUrl)
                },
                failure: { error in
                    self.connectViewController.dismiss(animated: true)
                    print(error)
                }
            )
        }
        connectViewController.add(qrCodeViewController)
        connectViewController.title = l10n(.scanQr)
    }

    private func showWebViewController() {
        webViewController.delegate = self
        connectViewController.add(webViewController)
        connectViewController.title = connectionType == .reconnect ? l10n(.reconnect) : l10n(.newConnection)
    }

    private func startWebViewLoading(with url: String) {
        showWebViewController()
        webViewController.startLoading(with: url)
    }

    private func loadUrl() {
        guard let connection = connection,
            let connectionData = SEConnectionData(code: connection.code, tag: connection.guid),
            let connectUrl = connection.baseUrl?.appendingPathComponent(SENetPaths.connections.path) else { return }

        SEConnectionManager.getConnectUrl(
            by: connectUrl,
            data: connectionData,
            pushToken: UserDefaultsHelper.pushToken,
            appLanguage: UserDefaultsHelper.applicationLanguage,
            onSuccess: { [weak self] response in
                self?.startWebViewLoading(with: response.connectUrl)
            },
            onFailure: { error in
                print(error)
            }
        )
    }
}

// MARK: - ConnectorWebViewControllerDelegate
extension ConnectViewCoordinator: ConnectorWebViewControllerDelegate {
    func connectorConfirmed(url: URL, accessToken: AccessToken) {
        guard let connection = connection else { return }

        ConnectionRepository.setAccessTokenAndActive(connection, accessToken: accessToken)
        ConnectionRepository.save(connection)

        webViewController.remove()
        connectViewController.navigationItem.leftBarButtonItem = nil
        let successTitleTemplate = l10n(.connectedSuccessfullyTitle)//"Your name is %@ and your age is %d."
        connectViewController.showCompleteView(with: .success, title: String(format: successTitleTemplate, connection.name))
    }

    func showError(_ error: String) {
        rootViewController.present(message: error, style: .error)
    }
}
