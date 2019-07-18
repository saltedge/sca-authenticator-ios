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

struct ConnectionsInteractor {
    static func getConnectUrl(from url: URL,
                              success: @escaping (Connection, String) -> (),
                              failure: @escaping (String) -> ()) {
        fetchProvider(
            from: url,
            success: { response in
                let connectionUrl = response.connectUrl.appendingPathComponent(SENetPaths.connections.path)

                let connection = Connection()

                guard let connectionData = SEConnectionData(code: response.code, tag: connection.guid) else { return }

                if ConnectionsCollector.connectionNames.contains(response.name) {
                    connection.name = "\(response.name) (\(ConnectionsCollector.connectionNames.count + 1))"
                } else {
                    connection.name = response.name
                }

                connection.logoUrlString = response.logoUrl?.absoluteString ?? ""
                connection.baseUrlString = response.connectUrl.absoluteString

                SEConnectionManager.getConnectUrl(
                    by: connectionUrl,
                    data: connectionData,
                    pushToken: UserDefaultsHelper.pushToken,
                    appLanguage: UserDefaultsHelper.applicationLanguage,
                     onSuccess: { response in
                        connection.id = response.id
                        success(connection, response.connectUrl)
                    },
                    onFailure: failure
                )
            },
            failure: failure
        )
    }

    static func fetchProvider(from url: URL,
                              success: @escaping (SEProviderResponse) -> (),
                              failure: @escaping (String) -> ()) {
        SEProviderManager.fetchProviderData(
            url: url,
            onSuccess: success,
            onFailure: failure
        )
    }

    static func revoke(_ connection: Connection, success: (() -> ())? = nil) {
        guard let baseUrl = connection.baseUrl else { return }

        let data = SERevokeConnectionData(id: connection.id, guid: connection.guid, token: connection.accessToken)

        SEConnectionManager.revokeConnection(
            by: baseUrl,
            data: data,
            appLanguage: UserDefaultsHelper.applicationLanguage,
            onSuccess: { _ in
                success?()
            },
            onFailure: { error in
                print(error)
            }
        )
    }
}
