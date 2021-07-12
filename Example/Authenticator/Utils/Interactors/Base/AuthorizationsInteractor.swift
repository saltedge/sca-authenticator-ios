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
import SEAuthenticatorV2
import SEAuthenticatorCore

struct AuthorizationsInteractor {
    static func confirm(
        apiVersion: ApiVersion,
        data: SEConfirmAuthorizationRequestData,
        successV1: (() -> ())? = nil,
        successV2: ((SEConfirmAuthorizationResponseV2) -> ())? = nil,
        failure: ((String) -> ())? = nil
    ) {
        if apiVersion == "2" {
            SEAuthorizationManagerV2.confirmAuthorization(
                data: data,
                onSuccess: { response in successV2?(response) },
                onFailure: { error in failure?(error) }
            )
        } else {
            SEAuthorizationManager.confirmAuthorization(
                data: data,
                onSuccess: { _ in successV1?() },
                onFailure: { error in failure?(error) }
            )
        }
    }

    static func deny(
        apiVersion: ApiVersion,
        data: SEConfirmAuthorizationRequestData,
        successV1: (() -> ())? = nil,
        successV2: ((SEConfirmAuthorizationResponseV2) -> ())? = nil,
        failure: ((String) -> ())? = nil
    ) {
        if apiVersion == "2" {
            SEAuthorizationManagerV2.denyAuthorization(
                data: data,
                onSuccess: { response in successV2?(response) },
                onFailure: { error in failure?(error) }
            )
        } else {
            SEAuthorizationManager.denyAuthorization(
                data: data,
                onSuccess: { _ in successV1?() },
                onFailure: { error in failure?(error) }
            )
        }
    }

    static func refresh(
        connection: Connection,
        authorizationId: ID,
        success: @escaping (SEBaseEncryptedAuthorizationData) -> (),
        failure: ((String) -> ())? = nil,
        connectionNotFoundFailure: @escaping ((String?) -> ())
    ) {
        let accessToken = connection.accessToken

        guard let baseUrl = connection.baseUrl else { failure?(l10n(.somethingWentWrong)); return }

        if connection.isApiV2 {
            SEAuthorizationManagerV2.getEncryptedAuthorization(
                data: SEBaseAuthenticatedWithIdRequestData(
                    url: baseUrl,
                    connectionGuid: connection.guid,
                    accessToken: accessToken,
                    appLanguage: UserDefaultsHelper.applicationLanguage,
                    entityId: authorizationId
                ),
                onSuccess: { response in
                    success(response.data)
                },
                onFailure: { error in
                    if SEAPIError.connectionNotFound.isConnectionNotFound(error) {
                        connectionNotFoundFailure(connection.id)
                    } else {
                        failure?("\(l10n(.somethingWentWrong)) (\(connection.name))")
                    }
                }
            )
        } else {
            SEAuthorizationManager.getEncryptedAuthorization(
                data: SEBaseAuthenticatedWithIdRequestData(
                    url: baseUrl,
                    connectionGuid: connection.guid,
                    accessToken: accessToken,
                    appLanguage: UserDefaultsHelper.applicationLanguage,
                    entityId: authorizationId
                ),
                onSuccess: { response in
                    success(response.data)
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
