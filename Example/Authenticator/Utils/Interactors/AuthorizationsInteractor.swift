//
//  AuthorizationsInteractor.swift
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

struct AuthorizationsInteractor {
    static func confirm(data: SEConfirmAuthorizationData,
                        success: (() -> ())? = nil,
                        failure: ((String) -> ())? = nil) {
        let expiresAt = Date().addingTimeInterval(5.0 * 60.0).utcSeconds

        SEAuthorizationManager.confirmAuthorization(
            data: data,
            expiresAt: expiresAt,
            onSuccess: { _ in
                success?()
            },
            onFailure: { error in
                failure?(error)
            }
        )
    }

    static func deny(data: SEConfirmAuthorizationData,
                     success: (() -> ())? = nil,
                     failure: ((String) -> ())? = nil) {
        let expiresAt = Date().addingTimeInterval(5.0 * 60.0).utcSeconds

        SEAuthorizationManager.denyAuthorization(
            data: data,
            expiresAt: expiresAt,
            onSuccess: { _ in
                success?()
            },
            onFailure: { error in
                failure?(error)
            }
        )
    }

    static func refresh(connections: [Connection],
                        success: @escaping ([SEEncryptedAuthorizationResponse]) -> (),
                        failure: ((String) -> ())? = nil,
                        connectionNotFoundFailure: @escaping ((String?) -> ())) {
        let expiresAt = Date().addingTimeInterval(5.0 * 60.0).utcSeconds

        var encryptedAuthorizations = [SEEncryptedAuthorizationResponse]()

        for connection in connections {
            let accessToken = connection.accessToken

            guard let baseUrl = connection.baseUrl else { failure?(l10n(.somethingWentWrong)); return }

            SEAuthorizationManager.getEncryptedAuthorizations(
                data: SEBaseAuthorizationData(
                    url: baseUrl,
                    connectionGuid: connection.guid,
                    accessToken: accessToken,
                    appLanguage: UserDefaultsHelper.applicationLanguage
                ),
                expiresAt: expiresAt,
                onSuccess: { response in
                    encryptedAuthorizations.append(contentsOf: response.data)

                    if encryptedAuthorizations != response.data {
                        success(encryptedAuthorizations)
                    }
                },
                onFailure: { error in
                    if SEAPIError.connectionNotFound.isConnectionNotFound(error) {
                        connectionNotFoundFailure(connection.id)
                    } else {
                        failure?("\(l10n(.somethingWentWrong)) (\(connection.name))")
                    }
                }
            )
        }
    }
}
