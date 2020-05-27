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

    private lazy var webViewController = ConnectorWebViewController()
    private var connectViewController = ConnectViewController()
    private var connectionId: String?
    private var connection: Connection?
    private let connectionType: ConnectionType

    init(rootViewController: UIViewController,
         connectionType: ConnectionType,
         connectionId: String? = nil) {
        self.rootViewController = rootViewController
        self.connectionType = connectionType
    }

    func start() {
        switch connectionType {
        case .reconnect: reconnectConnection()
        case .deepLink(let url): fetchConfiguration(url: url)
        case .newConnection(let metadata):
            if let qrUrl = URL(string: metadata), SEConnectHelper.isValid(deepLinkUrl: qrUrl) {
                self.fetchConfiguration(url: qrUrl)
            } else {
                self.connectViewController.dismiss(animated: true)
            }
        }

        rootViewController.present(
            UINavigationController(rootViewController: connectViewController),
            animated: true
        )
    }

    func stop() {}

    private func fetchConfiguration(url: URL) {
        guard let configurationUrl = SEConnectHelper.сonfiguration(from: url) else { return }

        let connectQuery = SEConnectHelper.connectQuery(from: url)

        showWebViewController()
        createNewConnection(from: configurationUrl, with: connectQuery)
    }

    private func createNewConnection(from configurationUrl: URL, with connectQuery: String?) {
        ConnectionsInteractor.createNewConnection(
            from: configurationUrl,
            with: connectQuery,
            success: { [weak self] connection, accessToken in
                self?.connection = connection
                self?.finishConnectWithSuccess(accessToken: accessToken)
            },
            redirect: { [weak self]  connection, connectUrl in
                self?.connection = connection
                self?.webViewController.startLoading(with: connectUrl)
            },
            failure: { [weak self] error in
                self?.dismissConnectWithError(error)
            }
        )
    }

    private func showWebViewController() {
        webViewController.delegate = self
        connectViewController.add(webViewController)
        connectViewController.title = connectionType == .reconnect ? l10n(.reconnect) : l10n(.newConnection)
    }

    private func reconnectConnection() {
        guard let connectionId = connectionId, let connection = ConnectionsCollector.with(id: connectionId) else { return }

        ConnectionsInteractor.submitConnection(
            for: connection,
            connectQuery: nil,
            success: { [weak self] connection, accessToken in
                self?.connection = connection
                self?.finishConnectWithSuccess(accessToken: accessToken)
            },
            redirect: { [weak self]  connection, connectUrl in
                self?.connection = connection
                self?.webViewController.startLoading(with: connectUrl)
            },
            failure: { [weak self] error in
                self?.dismissConnectWithError(error)
            }
        )
    }

    private func checkInternetConnection() {
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
    }
}

// MARK: - ConnectorWebViewControllerDelegate
extension ConnectViewCoordinator: ConnectorWebViewControllerDelegate {
    func connectorConfirmed(url: URL, accessToken: AccessToken) {
        finishConnectWithSuccess(accessToken: accessToken)
    }

    func showError(_ error: String) {
        finishConnectWithError(error)
    }
}

// MARK: - ConnectViewCoordinator: Finish
extension ConnectViewCoordinator {
    func finishConnectWithSuccess(accessToken: AccessToken) {
        guard let connection = connection else { return }

        ConnectionRepository.setAccessTokenAndActive(connection, accessToken: accessToken)
        ConnectionRepository.save(connection)

        webViewController.remove()
        connectViewController.navigationItem.leftBarButtonItem = nil
        let successTitleTemplate = l10n(.connectedSuccessfullyTitle)
        connectViewController.showCompleteView(with: .success, title: String(format: successTitleTemplate, connection.name))
    }

    func finishConnectWithError(_ error: String) {
        connectViewController.showCompleteView(with: .fail, title: error, description: l10n(.tryAgain))
    }

    func dismissConnectWithError(_ error: String) {
        connectViewController.dismiss(
            animated: true,
            completion: {
                self.rootViewController.present(message: error, style: .error)
            }
        )
    }
}
