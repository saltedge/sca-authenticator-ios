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
import CryptoSwift

public struct SEAuthorizationRequestData {
    public let id: ID
    public let authorizationCode: String
    public let userAuthorizationType: String
    public let geolocation: String
    public let connectionGuid: GUID

    public var encryptedData: SEEncryptedData? {
        guard let data = [
            SENetKeys.authorizationCode: authorizationCode,
            ApiConstants.userAuthorizationType: userAuthorizationType,
            ApiConstants.geolocation: geolocation
        ].jsonString else { return nil }

        return try? SECryptoHelper.encrypt(data, tag: SETagHelper.create(for: connectionGuid))
    }
}

enum SEAuthorizationRouter: Routable {
    case list(URL, AccessToken)
    case show(SEBaseAuthenticatedWithIdRequestData)
    case confirm(URL, AccessToken, SEAuthorizationRequestData)
    case deny(URL, AccessToken, SEAuthorizationRequestData)

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
        case .list(let url, _): return url.appendingPathComponent(
            "\(SENetPathBuilder(for: .authorizations, version: 2).path)"
        )
        case .show(let data):
            return data.url.appendingPathComponent(
                "\(SENetPathBuilder(for: .authorizations, version: 2).path)/\(data.entityId)"
            )
        case .confirm(let url, _, let data):
            return url.appendingPathComponent(
                "\(SENetPathBuilder(for: .authorizations, version: 2).path)/\(data.id)/confirm"
            )
        case .deny(let url, _, let data):
            return url.appendingPathComponent(
                "\(SENetPathBuilder(for: .authorizations, version: 2).path)/\(data.id)/deny"
            )
        }
    }
    
    var headers: [String : String]? {
        switch self {
        case .list(_, let accessToken):
            return Headers.authorizedRequestHeaders(token: accessToken)
        case .show(let data):
            return Headers.authorizedRequestHeaders(token: data.accessToken)
        case .confirm(_, let accessToken, let data), .deny(_, let accessToken, let data):
            return Headers.signedRequestHeaders(
                token: accessToken,
                payloadParams: parameters,
                connectionGuid: data.connectionGuid
            )
        }
    }
    
    var parameters: [String : Any]? {
        switch self {
        case .list, .show: return nil
        case .confirm(_, _, let data), .deny(_, _, let data):
            return RequestParametersBuilder.confirmAuthorizationParams(
                encryptedData: data.encryptedData,
                exp: Date().addingTimeInterval(5.0 * 60.0).utcSeconds
            )
        }
    }
}
