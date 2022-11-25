//
//  ConnectionsInteractor.swift
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

import Foundation
import SEAuthenticator
import SEAuthenticatorCore

struct ConnectionsInteractor: BaseConnectionsInteractor {
    func createNewConnection(
        from url: URL,
        with connectQuery: String?,
        success: @escaping (Connection, AccessToken) -> (),
        redirect: @escaping (Connection, String) -> (),
        failure: @escaping (String) -> ()
    ) {
        fetchProviderConfiguration(
            from: url,
            success: { response in
                let connection = Connection()
                connection.code = response.code

                if ConnectionsCollector.connectionNames.contains(response.name) {
                    connection.name = "\(response.name) (\(ConnectionsCollector.connectionNames.count + 1))"
                } else {
                    connection.name = response.name
                }

                connection.supportEmail = response.supportEmail
                connection.logoUrlString = response.logoUrl?.absoluteString ?? ""
                connection.baseUrlString = response.baseUrl.absoluteString
                connection.geolocationRequired.value = response.geolocationRequired

                submitNewConnection(
                    for: connection,
                    connectQuery: connectQuery,
                    success: success,
                    redirect: redirect,
                    failure: failure
                )
            },
            failure: failure
        )
    }

    func fetchProviderConfiguration(
        from url: URL,
        success: @escaping (SEProviderResponse) -> (),
        failure: @escaping (String) -> ()
    ) {
        SEProviderManager.fetchProviderData(
            url: url,
            onSuccess: success,
            onFailure: failure
        )
    }

    func submitNewConnection(
        for connection: Connection,
        connectQuery: String?,
        success: @escaping (Connection, AccessToken) -> (),
        redirect: @escaping (Connection, String) -> (),
        failure: @escaping (String) -> ()
    ) {
        guard let connectionData = SECreateConnectionRequestData(code: connection.code, tag: connection.guid),
            let connectUrl = connection.baseUrl else { return }

        SEConnectionManager.createConnection(
            by: connectUrl,
            data: connectionData,
            pushToken: UserDefaultsHelper.pushToken,
            connectQuery: connectQuery,
            appLanguage: UserDefaultsHelper.applicationLanguage,
            onSuccess: { response in
                connection.id = response.id
                if let accessToken = response.accessToken {
                    success(connection, accessToken)
                } else if let connectUrl = response.connectUrl {
                    redirect(connection, connectUrl)
                } else {
                    failure(l10n(.somethingWentWrong))
                }
            },
            onFailure: failure
        )
    }

    func revoke(
        _ connection: Connection,
        success: (() -> ())?,
        failure: @escaping (String) -> ()
    ) {
        guard let baseUrl = connection.baseUrl else { return }

        let data = SEBaseAuthenticatedWithIdRequestData(
            url: baseUrl,
            connectionGuid: connection.guid,
            accessToken: connection.accessToken,
            appLanguage: UserDefaultsHelper.applicationLanguage,
            entityId: connection.id
        )

        SEConnectionManager.revokeConnection(
            data: data,
            onSuccess: { _ in
                success?()
            },
            onFailure: failure
        )
    }
}
