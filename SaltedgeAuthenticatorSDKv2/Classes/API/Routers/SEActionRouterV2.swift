//
//  SEActionRouterV2
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

enum SEActionRouterV2: Routable {
    case submit(SEActionRequestDataV2)

    var method: HTTPMethod {
        return .post
    }

    var encoding: Encoding {
        return .json
    }

    var url: URL {
        switch self {
        case .submit(let data):
            return data.url.appendingPathComponent(SENetPathBuilder(for: .authorizations, version: 2).path)
        }
    }

    var headers: [String : String]? {
        switch self {
        case .submit(let data):
            return Headers.signedRequestHeaders(
                token: data.accessToken,
                payloadParams: RequestParametersBuilder.actionParameters(requestData: data),
                connectionGuid: data.connectionGuid
            )
        }
    }

    var parameters: [String : Any]? {
        switch self {
        case .submit(let data):
            return RequestParametersBuilder.actionParameters(requestData: data)
        }
    }
}
