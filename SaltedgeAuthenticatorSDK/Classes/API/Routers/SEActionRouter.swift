//
//  SEActionRouter
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

import Foundation
import SEAuthenticatorCore

enum SEActionRouter: Routable {
    case submit(SEActionRequestData)

    var method: HTTPMethod {
        return .put
    }

    var encoding: Encoding {
        return .json
    }

    var url: URL {
        switch self {
        case .submit(let data):
            return data.url.appendingPathComponent("\(SENetPathBuilder(for: .actions).path)/\(data.guid)")
        }
    }

    var headers: [String : String]? {
        switch self {
        case .submit(let data):
            let expiresAt = Date().addingTimeInterval(5.0 * 60.0).utcSeconds

            let signature = SignatureHelper.signedPayload(
                method: .put,
                urlString: data.url.appendingPathComponent(
                    "\(SENetPathBuilder(for: .actions).path)/\(data.guid)"
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
        }
    }

    var parameters: [String : Any]? {
        return nil
    }
}
