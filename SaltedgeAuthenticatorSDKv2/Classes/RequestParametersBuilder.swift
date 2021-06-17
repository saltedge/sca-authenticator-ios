//
//  RequestParametersBuilder
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

struct ParametersKeys {
    static let data = "data"
    static let key = "key"
    static let iv = "iv"
    static let actionId = "action_id"
    static let connectionId = "connection_id"
    static let providerId = "provider_id"
    static let publicKey = "public_key"
    static let deviceInfo = "device_info"
    static let platform = "platform"
    static let pushToken = "push_token"
    static let returnUrl = "return_url"
    static let connectQuery = "connect_query"
    static let confirm = "confirm"
    static let authorizationCode = "authorization_code"
    static let credentials = "credentials"
    static let encryptedRsaPublicKey = "enc_rsa_public_key"
    static let exp = "exp"
}

struct RequestParametersBuilder {
    static func parameters(for connectionParams: SECreateConnectionParams) -> [String: Any] {
        let encryptedRsaPublicKeyDict: [String: Any] = [
            ParametersKeys.data: connectionParams.encryptedRsaPublicKey.data,
            ParametersKeys.key: connectionParams.encryptedRsaPublicKey.key,
            ParametersKeys.iv: connectionParams.encryptedRsaPublicKey.iv,
        ]

        var data: [String: Any] = [
            ParametersKeys.providerId: connectionParams.providerId,
            ParametersKeys.returnUrl: SENetConstants.oauthRedirectUrl,
            ParametersKeys.platform: "ios",
            ParametersKeys.encryptedRsaPublicKey: encryptedRsaPublicKeyDict
        ]

        if let pushToken = connectionParams.pushToken, !pushToken.isEmpty {
            data = data.merge(with: [ParametersKeys.pushToken: pushToken])
        }
        if let connectQuery = connectionParams.connectQuery, !connectQuery.isEmpty {
            data = data.merge(with: [ParametersKeys.connectQuery: connectQuery])
        }

        return [ParametersKeys.data: data]
    }

    static func confirmAuthorizationParams(encryptedData: SEEncryptedData?, exp: Int) -> [String: Any] {
        guard let encryptedData = encryptedData else { return [:] }

        let encryptedDataParams = [
            SENetKeys.data: encryptedData.data,
            SENetKeys.key: encryptedData.key,
            SENetKeys.iv: encryptedData.iv
        ]

        return [
            ParametersKeys.data: encryptedDataParams,
            ParametersKeys.exp: exp
        ]
    }

    static func actionParameters(requestData: SEActionRequestDataV2) -> [String: Any] {
        return [
            SENetKeys.data: [
                ParametersKeys.providerId: requestData.providerId,
                ParametersKeys.actionId: requestData.actionId,
                ParametersKeys.connectionId: requestData.connectionId
            ],
            ParametersKeys.exp: Date().addingTimeInterval(5.0 * 60.0).utcSeconds
        ]
    }
}
