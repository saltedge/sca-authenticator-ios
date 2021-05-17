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
    public let providerId: String
    public let returnUrl: String
    public let platform: String
    public let pushToken: String?
    public let connectQuery: String?
    public let encryptedRsaPublicKey: SEEncryptedData
}

// TODO: Add revoke connection case
enum SEConnectionRouter: Routable {
    case createConnection(URL, SECreateConnectionParams, String)

    var method: HTTPMethod {
        switch self {
        case .createConnection: return .post
        }
    }

    var encoding: Encoding {
        switch self {
        case .createConnection: return .json
        }
    }

    var url: URL {
        switch self {
        case .createConnection(let connectUrl, _, _): return connectUrl
        }
    }

    var headers: [String: String]? {
        switch self {
        case .createConnection(_, _, let appLanguage): return Headers.requestHeaders(with: appLanguage)
        }
    }

    var parameters: [String: Any]? {
        switch self {
        case .createConnection(_, let data, _):
            return RequestParametersBuilder.parameters(for: data)
        }
    }
}
