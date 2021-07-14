//
//  SEConsentRouterV2
//  This file is part of the Salt Edge Authenticator distribution
//  (https://github.com/saltedge/sca-authenticator-ios)
//  Copyright © 2021 Salt Edge Inc.
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

import Foundation
import SEAuthenticatorCore

enum SEConsentRouter: Routable {
    case list(SEBaseAuthenticatedRequestData)
    case revoke(SEBaseAuthenticatedWithIdRequestData)

    var method: HTTPMethod {
        switch self {
        case .list: return .get
        case .revoke: return .delete
        }
    }

    var encoding: Encoding {
        switch self {
        case .list, .revoke: return .url
        }
    }

    var url: URL {
        switch self {
        case .list(let data):
            return data.url.appendingPathComponent(
                SENetPathBuilder(for: .consents, version: 2).path
            )
        case .revoke(let data):
            return data.url.appendingPathComponent(
                "\(SENetPathBuilder(for: .consents, version: 2).path)/\(data.entityId)/revoke"
            )
        }
    }
    
    var parameters: [String: Any]? {
        switch self {
        case .list: return nil
        case .revoke:
            return RequestParametersBuilder.expirationTimeParameters
        }
    }

    var headers: [String: String]? {
        switch self {
        case .list(let data):
            return Headers.authorizedRequestHeaders(token: data.accessToken)
        case .revoke(let data):
            return Headers.signedRequestHeaders(
                token: data.accessToken,
                payloadParams: RequestParametersBuilder.expirationTimeParameters,
                connectionGuid: data.connectionGuid
            )
        }
    }
}
