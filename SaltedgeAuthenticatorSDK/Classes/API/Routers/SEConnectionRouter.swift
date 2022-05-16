//
//  SEConnectionRouter.swift
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
import SEAuthenticatorCore

enum SEConnectionRouter: Routable {
    case createConnection(URL, SECreateConnectionRequestData, PushToken, ConnectQuery?, ApplicationLanguage)
    case revoke(SEBaseAuthenticatedWithIdRequestData)

    var method: HTTPMethod {
        switch self {
        case .createConnection: return .post
        case .revoke: return .delete
        }
    }

    var encoding: Encoding {
        switch self {
        case .createConnection: return .json
        case .revoke: return .url
        }
    }

    var url: URL {
        switch self {
        case .createConnection(let url, _, _, _, _):
            return url.appendingPathComponent(SENetPathBuilder(for: .connections).path)
        case .revoke(let data):
            return data.url.appendingPathComponent(SENetPathBuilder(for: .connections).path)
        }
    }

    var headers: [String: String]? {
        switch self {
        case .createConnection(_, _, _, _, let appLanguage): return Headers.requestHeaders(with: appLanguage)
        case .revoke(let data):
            let expiresAt = Date().addingTimeInterval(5.0 * 60.0).utcSeconds
            
            let signature = SignatureHelper.signedPayload(
                method: .delete,
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
        }
    }

    var parameters: [String: Any]? {
        switch self {
        case .createConnection(_, let data, let pushToken, let connectQuery, _):
            return RequestParametersBuilder.parameters(
                for: data,
                pushToken: pushToken,
                connectQuery: connectQuery
            )
        case .revoke: return nil
        }
    }
}
