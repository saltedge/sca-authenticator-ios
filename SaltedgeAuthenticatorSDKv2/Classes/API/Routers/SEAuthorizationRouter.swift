//
//  SEAuthorizationRouter
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
import SEAuthenticatorCore

enum SEAuthorizationRouter: Routable {
    case list(SEBaseAuthenticatedRequestData)
    case show(SEBaseAuthenticatedWithIdRequestData)
    case confirm(SEConfirmAuthorizationRequestData, [String: Any])
    case deny(SEConfirmAuthorizationRequestData, [String: Any])

    var method: HTTPMethod {
        switch self {
        case .list, .show: return .get
        case .confirm, .deny: return .put
        }
    }
    
    var encoding: Encoding {
        switch self {
        case .list, .show: return .url
        case .confirm, .deny: return .json
        }
    }
    
    var url: URL {
        switch self {
        case .list(let data):
            return data.url.appendingPathComponent(
                "\(SENetPathBuilder(for: .authorizations, version: 2).path)"
            )
        case .show(let data):
            return data.url.appendingPathComponent(
                "\(SENetPathBuilder(for: .authorizations, version: 2).path)/\(data.entityId)"
            )
        case .confirm(let data, _):
            return data.url.appendingPathComponent(
                "\(SENetPathBuilder(for: .authorizations, version: 2).path)/\(data.entityId)/confirm"
            )
        case .deny(let data, _):
            return data.url.appendingPathComponent(
                "\(SENetPathBuilder(for: .authorizations, version: 2).path)/\(data.entityId)/deny"
            )
        }
    }
    
    var headers: [String : String]? {
        switch self {
        case .list(let data):
            return Headers.authorizedRequestHeaders(token: data.accessToken)
        case .show(let data):
            return Headers.authorizedRequestHeaders(token: data.accessToken)
        case .confirm(let data, let encryptedParameters), .deny(let data, let encryptedParameters):
            return Headers.signedRequestHeaders(
                token: data.accessToken,
                payloadParams: encryptedParameters,
                connectionGuid: data.connectionGuid
            )
        }
    }
    
    var parameters: [String : Any]? {
        switch self {
        case .list, .show: return nil
        case .confirm(_, let encryptedParameters), .deny(_, let encryptedParameters): return encryptedParameters
        }
    }
}
