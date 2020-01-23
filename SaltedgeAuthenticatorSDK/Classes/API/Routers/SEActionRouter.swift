//
//  SEActionRouter
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

enum SEActionRouter: Routable {
    case perform(SEActionData, GUID)

    var method: HTTPMethod {
        return .post
    }

    var encoding: Encoding {
        return .json
    }

    var url: URL {
        switch self {
        case .perform(let data, let actionGuid):
            return data.url.appendingPathComponent("\(SENetPaths.action.path)/\(actionGuid)")
        }
    }

    var headers: [String : String]? {
        switch self {
        case .perform(let data, let actionGuid):
            let expiresAt = Date().addingTimeInterval(5.0 * 60.0).utcSeconds

            let signature = SignatureHelper.signedPayload(
                method: .post,
                urlString: data.url.appendingPathComponent("\(SENetPaths.action.path)/\(actionGuid)").absoluteString,
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

    var parameters: [String : Any]? {
        return nil
    }
}
