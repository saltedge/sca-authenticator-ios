//
//  InstantActionHandler
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

import UIKit
import SEAuthenticator
import SEAuthenticatorV2
import SEAuthenticatorCore

protocol InstantActionEventsDelegate: class {
    func shouldPresentConnectionPicker(connections: [Connection])
    func shouldDismiss()
    func showAuthorization(connectionId: String, authorizationId: String)
    func shouldDismiss(with error: String)
    func errorReceived(error: String)
}

final class InstantActionHandler {
    private var qrUrl: URL

    weak var delegate: InstantActionEventsDelegate?

    init(qrUrl: URL) {
        self.qrUrl = qrUrl
    }

    private var actionGuid: GUID? {
        return SEConnectHelper.actionGuid(from: qrUrl)
    }

    private var connectUrl: URL? {
        return SEConnectHelper.connectUrl(from: qrUrl)
    }

    private var apiVersion: ApiVersion {
        return SEConnectHelper.apiVersion(from: qrUrl) ?? "1"
    }

    func startHandling() {
        handleQr(qrUrl: qrUrl)
    }

    func submitAction(for submitData: SubmitActionData) {
        if apiVersion == "2" {
            guard let providerId = qrUrl.queryItem(for: SENetKeys.providerId),
                  let actionId = qrUrl.queryItem(for: SENetKeys.actionId) else { return }

            let actionData = SEActionRequestDataV2(
                url: submitData.baseUrl,
                connectionGuid: submitData.connectionGuid,
                accessToken: submitData.accessToken,
                appLanguage: UserDefaultsHelper.applicationLanguage,
                providerId: providerId,
                actionId: actionId,
                connectionId: submitData.connectionId
            )

            SEActionManagerV2.submitAction(
                data: actionData,
                onSuccess: { [weak self] response in
                    guard let strongSelf = self else { return }

                    strongSelf.handleActionResponse(response, qrUrl: strongSelf.qrUrl)
                },
                onFailure: { [weak self] _ in
                    DispatchQueue.main.async {
                        self?.delegate?.errorReceived(error: l10n(.actionError))
                    }
                }
            )
        } else {
            let actionData = SEActionRequestData(
                url: connectUrl!,
                connectionGuid: submitData.connectionGuid,
                accessToken: submitData.accessToken,
                appLanguage: UserDefaultsHelper.applicationLanguage,
                guid: actionGuid!
            )

            SEActionManager.submitAction(
                data: actionData,
                onSuccess: { [weak self] response in
                    guard let strongSelf = self else { return }

                    strongSelf.handleActionResponse(response, qrUrl: strongSelf.qrUrl)
                },
                onFailure: { [weak self] _ in
                    DispatchQueue.main.async {
                        self?.delegate?.errorReceived(error: l10n(.actionError))
                    }
                }
            )
        }
    }

    private func handleQr(qrUrl: URL) {
        guard ConnectionsCollector.activeConnections.count > 0 else {
            self.delegate?.errorReceived(error: l10n(.noActiveConnection))
            return
        }

        var connections = [Connection]()

        if apiVersion == "2", let providerId = SEConnectHelper.providerId(from: qrUrl) {
            connections = ConnectionsCollector.activeConnections(by: providerId)
        } else if let connectUrl = connectUrl {
            connections = ConnectionsCollector.activeConnections(by: connectUrl)
        }

        if connections.count > 1 {
            delegate?.shouldPresentConnectionPicker(connections: connections)
        } else if connections.count == 1 {
            guard let connection = connections.first, let baseUrl = connection.baseUrl else { return }

            submitAction(
                for: SubmitActionData(
                    baseUrl: baseUrl,
                    connectionGuid: connection.guid,
                    connectionId: connection.id,
                    accessToken: connection.accessToken,
                    apiVersion: connection.apiVersion
                )
            )
        } else {
            delegate?.shouldDismiss(with: l10n(.noSuitableConnection))
        }
    }

    private func handleActionResponse(_ response: SEBaseActionResponse, qrUrl: URL) {
        if let connectionId = response.connectionId,
            let authorizationId = response.authorizationId {
            delegate?.showAuthorization(connectionId: connectionId, authorizationId: authorizationId)
        } else {
            if let returnTo = SEConnectHelper.returnToUrl(from: qrUrl) {
                UIApplication.shared.open(returnTo)
            } else {
                delegate?.shouldDismiss()
            }
        }
    }
}
