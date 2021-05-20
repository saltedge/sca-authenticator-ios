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
    private var actionGuid: GUID
    private var connectUrl: URL

    weak var delegate: InstantActionEventsDelegate?

    init(qrUrl: URL, actionGuid: GUID, connectUrl: URL) {
        self.qrUrl = qrUrl
        self.actionGuid = actionGuid
        self.connectUrl = connectUrl
    }

    func startHandling() {
        handleQr(qrUrl: qrUrl, actionGuid: actionGuid, connectUrl: connectUrl)
    }

    private func handleQr(qrUrl: URL, actionGuid: GUID, connectUrl: URL) {
        guard ConnectionsCollector.activeConnections.count > 0 else {
            self.delegate?.errorReceived(error: l10n(.noActiveConnection))
            return
        }

        let connections = ConnectionsCollector.activeConnections(by: connectUrl)

        if connections.count > 1 {
            delegate?.shouldPresentConnectionPicker(connections: connections)
        } else if connections.count == 1 {
            guard let connection = connections.first else { return }

            submitAction(
                for: connection.guid,
                accessToken: connection.accessToken
            )
        } else {
            delegate?.shouldDismiss(with: l10n(.noSuitableConnection))
        }
    }

    func submitAction(for connectionGuid: GUID, accessToken: AccessToken) {
        let actionData = SEActionRequestData(
            url: connectUrl,
            connectionGuid: connectionGuid,
            accessToken: accessToken,
            appLanguage: UserDefaultsHelper.applicationLanguage,
            guid: actionGuid
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

    private func handleActionResponse(_ response: SESubmitActionResponse, qrUrl: URL) {
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
