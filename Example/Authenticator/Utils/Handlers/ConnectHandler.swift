//
//  ConnectHandler.swift
//  This file is part of the Salt Edge Authenticator distribution
//  (https://github.com/saltedge/sca-authenticator-ios)
//  Copyright © 2020 Salt Edge Inc.
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

import Foundation
import SEAuthenticatorCore

protocol ConnectEventsDelegate: AnyObject {
    func showWebViewController()
    func finishConnectWithSuccess(attributedMessage: NSMutableAttributedString)
    func startWebViewLoading(with connectUrlString: String)
    func dismiss()
    func dismissConnectWithError(error: String)
    func requestLocationAuthorization()
}

final class ConnectHandler {
    private var connection: Connection?
    private var connectionType: ConnectionType?

    weak var delegate: ConnectEventsDelegate?

    init(connectionType: ConnectionType) {
        self.connectionType = connectionType
    }

    func startHandling() {
        switch connectionType {
        case .reconnect(let connectionId): reconnectConnection(connectionId)
        case .deepLink(let url): fetchConfiguration(url: url)
        case .newConnection(let metadata):
            if let qrUrl = URL(string: metadata), SEConnectHelper.isValid(deepLinkUrl: qrUrl) {
                self.fetchConfiguration(url: qrUrl)
            } else {
                self.delegate?.dismiss()
            }
        default: break
        }
    }

    func saveConnectionAndFinish(with accessToken: AccessToken) {
        guard let connection = connection else { return }

        ConnectionRepository.setAccessTokenAndActive(
            connection,
            accessToken: connection.isApiV2 ? decryptedAccessToken(accessToken, for: connection) : accessToken
        )

        ConnectionRepository.save(connection)
        let attributedConnectionName = NSAttributedString(
            string: connection.name,
            attributes: [NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: 21.0)]
        )
        let description = NSAttributedString(string: " \(l10n(.connectedSuccessfullyTitle))")
        let finalString = NSMutableAttributedString()
        finalString.append(attributedConnectionName)
        finalString.append(description)
        delegate?.finishConnectWithSuccess(attributedMessage: finalString)

        if connection.geolocationRequired.value != nil {
            delegate?.requestLocationAuthorization()
        }
    }
}

// Private methods
private extension ConnectHandler {
    func fetchConfiguration(url: URL) {
        guard let configurationUrl = SEConnectHelper.сonfiguration(from: url) else { return }

        let connectQuery = SEConnectHelper.connectQuery(from: url)

        delegate?.showWebViewController()

        let apiVersion = configurationUrl.absoluteString.apiVerion
        createNewConnection(
            from: configurationUrl,
            with: connectQuery,
            interactor: apiVersion == "2" ? ConnectionsInteractorV2() : ConnectionsInteractor()
        )
    }

    func createNewConnection(
        from configurationUrl: URL,
        with connectQuery: String?,
        interactor: BaseConnectionsInteractor
    ) {
        interactor.createNewConnection(
            from: configurationUrl,
            with: connectQuery,
            success: { [weak self] connection, accessToken in
                self?.connection = connection
                self?.saveConnectionAndFinish(with: accessToken)
            },
            redirect: { [weak self]  connection, connectUrl in // url designated for user authorization
                self?.connection = connection
                self?.delegate?.startWebViewLoading(with: connectUrl)
            },
            failure: { [weak self] error in
                self?.dismissConnectWithError(error: error)
            }
        )
    }

    func reconnectConnection(_ connectionId: String) {
        guard let connection = ConnectionsCollector.with(id: connectionId) else { return }

        let interactor: BaseConnectionsInteractor = connection.isApiV2
            ? ConnectionsInteractorV2() : ConnectionsInteractor()

        interactor.submitNewConnection(
            for: connection,
            connectQuery: nil,
            success: { [weak self] connection, accessToken in
                self?.connection = connection
                self?.saveConnectionAndFinish(with: accessToken)
            },
            redirect: { [weak self]  connection, connectUrl in
                self?.connection = connection
                self?.delegate?.startWebViewLoading(with: connectUrl)
            },
            failure: { [weak self] error in
                self?.dismissConnectWithError(error: error)
            }
        )
    }

    func decryptedAccessToken(_ token: String, for connection: Connection) -> String? {
        guard let decryptedTokenData = try? SECryptoHelper.decrypt(key: token, tag: SETagHelper.create(for: connection.guid)).json,
              let decryptedAccessToken = decryptedTokenData[SENetKeys.accessToken] as? String else {
            return nil
        }

        return decryptedAccessToken
    }

    func dismissConnectWithError(error: String) {
        DispatchQueue.main.async {
            self.delegate?.dismissConnectWithError(error: error)
        }
    }
}
