//
//  SEAuthorizationRouter.swift
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

enum SEAuthorizationRouter: Routable {
    case list(SEBaseAuthenticatedRequestData)
    case getAuthorization(SEBaseAuthenticatedWithIdRequestData)
    case confirm(SEConfirmAuthorizationRequestData)
    case deny(SEConfirmAuthorizationRequestData)

    var method: HTTPMethod {
        switch self {
        case .list, .getAuthorization: return .get
        case .confirm, .deny: return .put
        }
    }

    var encoding: Encoding {
        switch self {
        case .list, .getAuthorization: return .url
        case .confirm, .deny: return .json
        }
    }

    var url: URL {
        switch self {
        case .list(let data):
            return data.url.appendingPathComponent(SENetPaths.authorizations.path)
        case .getAuthorization(let data):
            return data.url.appendingPathComponent("\(SENetPaths.authorizations.path)/\(data.entityId)")
        case .confirm(let data), .deny(let data):
            return data.url.appendingPathComponent("\(SENetPaths.authorizations.path)/\(data.entityId)")
        }
    }

    var headers: [String: String]? {
        switch self {
        case .list(let data):
            let expiresAt = Date().addingTimeInterval(5.0 * 60.0).utcSeconds
            
            let signature = SignatureHelper.signedPayload(
                method: .get,
                urlString: url.absoluteString,
                guid: data.connectionGuid,
                expiresAt: expiresAt,
                params: parameters
            )

            return Headers.signedRequestHeaders(
                token: data.accessToken,
                expiresAt: expiresAt,
                signature: signature,
                appLanguage: data.appLanguage
            )
        case .getAuthorization(let data):
            let expiresAt = Date().addingTimeInterval(5.0 * 60.0).utcSeconds
            
            let signature = SignatureHelper.signedPayload(
                method: .get,
                urlString: data.url.appendingPathComponent(
                    "\(SENetPaths.authorizations.path)/\(data.entityId)"
                    ).absoluteString,
                guid: data.connectionGuid,
                expiresAt: expiresAt,
                params: parameters
            )

            return Headers.signedRequestHeaders(
                token: data.accessToken,
                expiresAt: expiresAt,
                signature: signature,
                appLanguage: data.appLanguage
            )
        case .confirm(let data), .deny(let data):
            let expiresAt = Date().addingTimeInterval(5.0 * 60.0).utcSeconds
            
            let signature = SignatureHelper.signedPayload(
                method: .put,
                urlString: data.url.appendingPathComponent(
                    "\(SENetPaths.authorizations.path)/\(data.entityId)"
                    ).absoluteString,
                guid: data.connectionGuid,
                expiresAt: expiresAt,
                params: parameters
            )

            return Headers.signedRequestHeaders(
                token: data.accessToken,
                expiresAt: expiresAt,
                signature: signature,
                appLanguage: data.appLanguage
            )
            .addLocationHeader(geolocation: data.geolocation)
            .addAuthorizationTypeHeader(authorizationType: data.authorizationType)
        }
    }

    var parameters: [String: Any]? {
        switch self {
        case .list, .getAuthorization: return nil
        case .confirm(let data):
            return RequestParametersBuilder.confirmAuthorization(true, authorizationCode: data.authorizationCode)
        case .deny(let data):
            return RequestParametersBuilder.confirmAuthorization(false, authorizationCode: data.authorizationCode)
        }
    }
}
