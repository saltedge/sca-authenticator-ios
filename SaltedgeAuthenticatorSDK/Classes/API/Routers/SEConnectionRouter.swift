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

enum SEConnectionRouter: Routable {
    case getConnectUrl(URL, SEConnectionData, PushToken, ConnectQuery?, ApplicationLanguage)
    case revoke(URL, SERevokeConnectionData, ApplicationLanguage)

    var method: HTTPMethod {
        switch self {
        case .getConnectUrl: return .post
        case .revoke: return .delete
        }
    }

    var encoding: Encoding {
        switch self {
        case .getConnectUrl: return .json
        case .revoke: return .url
        }
    }

    var url: URL {
        switch self {
        case .getConnectUrl(let url, _, _, _, _): return url
        case .revoke(let url, _, _): return url.appendingPathComponent("\(SENetPaths.connections.path)")
        }
    }

    var headers: [String: String]? {
        switch self {
        case .getConnectUrl(_, _, _, _, let appLanguage): return Headers.requestHeaders(with: appLanguage)
        case .revoke(_, let data, let appLanguage):
            let signature = SignatureHelper.signedPayload(
                method: .delete,
                urlString: url.absoluteString,
                guid: data.guid,
                params: parameters
            )

            return Headers.signedRequestHeaders(token: data.token,
                                                signature: signature,
                                                appLanguage: appLanguage)
        }
    }

    var parameters: [String: Any]? {
        switch self {
        case .getConnectUrl(_, let data, let pushToken, let connectQuery, _):
            return RequestParametersBuilder.parameters(for: data,
                                                       pushToken: pushToken,
                                                       connectQuery: connectQuery)
        case .revoke: return nil
        }
    }
}
