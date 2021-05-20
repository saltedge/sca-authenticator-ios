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
    static let encryptedRsaPublicKey = "encrypted_rsa_public_key"
    static let exp = "exp"
}

struct RequestParametersBuilder {
    static func parameters(for connectionParams: SECreateConnectionParams) -> [String: Any] {
        let encryptedRsaPublicKeyDict: [String: Any] = [
            ParametersKeys.data: connectionParams.encryptedRsaPublicKey.data,
            ParametersKeys.key: connectionParams.encryptedRsaPublicKey.key,
            ParametersKeys.iv: connectionParams.encryptedRsaPublicKey.iv,
        ]

        return [
            ParametersKeys.data: [
                ParametersKeys.providerId: connectionParams.providerId,
                ParametersKeys.returnUrl: SENetConstants.oauthRedirectUrl,
                ParametersKeys.platform: "ios",
                ParametersKeys.pushToken: connectionParams.pushToken,
                ParametersKeys.encryptedRsaPublicKey: encryptedRsaPublicKeyDict,
                ParametersKeys.connectQuery: connectionParams.connectQuery
            ]
        ]
    }

    static func confirmAuthorization(_ confirm: Bool, authorizationCode: String?) -> [String: Any] {
        var data: [String: Any] = [ParametersKeys.confirm: confirm]

        if let authorizationCode = authorizationCode {
            data = data.merge(with: [ParametersKeys.authorizationCode: authorizationCode])
        }

        return [ParametersKeys.data: data]
    }
}
