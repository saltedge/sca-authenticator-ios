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
    private let deepLinkUrl: URL?

    init(rootViewController: UIViewController,
         connectionType: ConnectionType,
         deepLinkUrl: URL? = nil,
         connection: Connection? = nil) {
        self.deepLinkUrl = deepLinkUrl
        self.rootViewController = rootViewController
        self.connection = connection
        self.connectionType = connectionType
    }

    func start() {
        switch connectionType {
        case .reconnect: loadUrl()
        case .connect: showQrCodeViewController()
        case .deepLink:
            if let url = deepLinkUrl {
                fetchConfiguration(deepLinkUrl: url)
            } else {
                showQrCodeViewController()
            }
        }

        let navigationController = UINavigationController(rootViewController: connectViewController)
        navigationController.modalPresentationStyle = .fullScreen
        rootViewController.present(
            navigationController,
            animated: true
        )
    }

    func stop() {}

    private func fetchConfiguration(deepLinkUrl: URL) {
        guard let configurationUrl = SEConnectHelper.сonfiguration(from: deepLinkUrl) else { return }

        let connectQuery = SEConnectHelper.connectQuery(from: deepLinkUrl)

        showWebViewController()
        getConnectUrl(from: configurationUrl, with: connectQuery)
    }

    private func showQrCodeViewController() {
        qrCodeViewController.metadataReceived = { vc, qrMetadata in
            vc.remove()

            self.checkInternetConnection()

            if let qrUrl = URL(string: qrMetadata), SEConnectHelper.isValid(deepLinkUrl: qrUrl) {
                self.handleQr(url: qrUrl)
            } else {
                self.connectViewController.dismiss(animated: true)
            }
        }
        connectViewController.add(qrCodeViewController)
        connectViewController.title = l10n(.scanQr)
    }

    private func handleQr(url: URL) {
        if let actionGuid = SEConnectHelper.actionGuid(from: url),
            let connectUrl = SEConnectHelper.connectUrl(from: url) {
            connectViewController.startLoading()

            guard ConnectionsCollector.activeConnections.count > 1 else {
                if let connection = ConnectionsCollector.activeConnections.first {
                    let actionData = SEActionData(
                        url: connectUrl,
                        guid: actionGuid,
                        connectionGuid: connection.guid,
                        accessToken: connection.accessToken,
                        appLanguage: UserDefaultsHelper.applicationLanguage
                    )
                    self.submitAction(actionData: actionData, actionGuid: actionGuid, qrUrl: url)
                }
                return
            }

            presentConnectionPicker(with: actionGuid, connectUrl: connectUrl, qrUrl: url)
        } else {
            fetchConfiguration(deepLinkUrl: url)
        }
    }

    private func presentConnectionPicker(with actionGuid: GUID, connectUrl: URL, qrUrl: URL) {
        let pickerVc = ConnectionPickerViewController()
        pickerVc.selectedConnection = { connection in
            let actionData = SEActionData(
                url: connectUrl,
                guid: actionGuid,
                connectionGuid: connection.guid,
                accessToken: connection.accessToken,
                appLanguage: UserDefaultsHelper.applicationLanguage
            )

            self.submitAction(actionData: actionData, actionGuid: actionGuid, qrUrl: qrUrl)
        }
        pickerVc.cancelPressedClosure = {
            self.rootViewController.dismiss(animated: true)
        }
        let pickerNavVc = UINavigationController(rootViewController: pickerVc)
        pickerNavVc.modalPresentationStyle = .fullScreen
        connectViewController.present(pickerNavVc, animated: true)
    }

    private func submitAction(actionData: SEActionData, actionGuid: GUID, qrUrl: URL) {
        SEActionManager.submitAction(
            data: actionData,
            onSuccess: { response in
                self.connectViewController.stopLoading()

                self.handleActionResponse(response, qrUrl: qrUrl)
            },
            onFailure: { _ in
                self.connectViewController.stopLoading()
                self.connectViewController.showCompleteView(with: .fail, title: l10n(.somethingWentWrong))
            }
        )
    }

    private func handleActionResponse(_ response: SESubmitActionResponse, qrUrl: URL) {
        if let connectionId = response.connectionId,
            let authorizationId = response.authorizationId {
            AppDelegate.main.applicationCoordinator?.showAuthorizations(
                connectionId: connectionId,
                authorizationId: authorizationId
            )
        } else {
            self.connectViewController.showCompleteView(
                with: .success,
                title: l10n(.instantActionSuccessMessage),
                description: l10n(.instantActionSuccessDescription),
                completion: {
                    if let returnTo = SEConnectHelper.returnToUrl(from: qrUrl) {
                        UIApplication.shared.open(returnTo)
                    }
                }
            )
        }
    }

    private func getConnectUrl(from configurationUrl: URL, with connectQuery: String?) {
        ConnectionsInteractor.getConnectUrl(
            from: configurationUrl,
            with: connectQuery,
            success: { [weak self]  connection, connectUrl in
                guard let strongSelf = self else { return }

                strongSelf.connection = connection
                strongSelf.webViewController.startLoading(with: connectUrl)
            },
            failure: { [weak self] error in
                self?.connectViewController.dismiss(
                    animated: true,
                    completion: {
                        self?.rootViewController.present(message: error, style: .error)
                    }
                )
            }
        )
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
        guard let connection = connection else { return }

        ConnectionRepository.setAccessTokenAndActive(connection, accessToken: accessToken)
        ConnectionRepository.save(connection)

        webViewController.remove()
        connectViewController.navigationItem.leftBarButtonItem = nil
        let successTitleTemplate = l10n(.connectedSuccessfullyTitle)
        connectViewController.showCompleteView(with: .success, title: String(format: successTitleTemplate, connection.name))
    }

    func showError(_ error: String) {
        connectViewController.showCompleteView(with: .fail, title: error, description: l10n(.tryAgain))
    }
}
