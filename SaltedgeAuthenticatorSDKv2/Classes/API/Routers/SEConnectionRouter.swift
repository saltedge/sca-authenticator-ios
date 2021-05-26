//
//  SEConnectionRouter.swift
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

public struct SECreateConnectionParams {
    public let providerId: Int
    public let pushToken: String?
    public let connectQuery: String?
    public let encryptedRsaPublicKey: SEEncryptedData

    public init(providerId: Int, pushToken: String?, connectQuery: String?, encryptedRsaPublicKey: SEEncryptedData) {
        self.providerId = providerId
        self.pushToken = pushToken
        self.connectQuery = connectQuery
        self.encryptedRsaPublicKey = encryptedRsaPublicKey
    }
}

enum SEConnectionRouter: Routable {
    case createConnection(URL, SECreateConnectionParams, String)
    case revoke(SEBaseAuthenticatedWithIdRequestData)

    var method: HTTPMethod {
        switch self {
        case .createConnection: return .post
        case .revoke: return .delete
        }
    }

    var encoding: Encoding {
        switch self {
        case .createConnection, .revoke: return .json
        }
    }

    var url: URL {
        switch self {
        case .createConnection(let connectUrl, _, _):
            return connectUrl.appendingPathComponent(SENetPathBuilder(for: .connections, version: 2).path)
        case .revoke(let data):
            return data.url.appendingPathComponent(
                "\(SENetPathBuilder(for: .connections, version: 2).path)/\(data.entityId)/revoke"
            )
        }
    }

    var headers: [String: String]? {
        switch self {
        case .createConnection(_, _, let appLanguage):
            return Headers.requestHeaders(with: appLanguage)
        case .revoke(let data):
            return Headers.signedRequestHeaders(
                token: data.accessToken,
                payloadParams: parameters,
                connectionGuid: data.connectionGuid
            )
        }
    }

    var parameters: [String: Any]? {
        switch self {
        case .createConnection(_, let data, _):
            return RequestParametersBuilder.parameters(for: data)
        case .revoke:
            return [
                ParametersKeys.data: [:],
                ParametersKeys.exp: Date().addingTimeInterval(5.0 * 60.0).utcSeconds
            ]
        }
    }
}
