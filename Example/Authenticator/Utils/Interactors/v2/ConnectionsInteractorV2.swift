//
//  ConnectionsInteractorV2
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
import SEAuthenticatorV2
import SEAuthenticatorCore

struct ConnectionsInteractorV2 {
    /*
      Request to create new SCA Service connection.
      Result is returned through callback.
    */
    static func createNewConnection(
        from url: URL,
        with connectQuery: String?,
        success: @escaping (Connection, AccessToken) -> (),
        redirect: @escaping (Connection, String) -> (),
        failure: @escaping (String) -> ()
    ) {
        getProviderConfiguration(
            from: url,
            success: { response in
                let connection = Connection()

                if ConnectionsCollector.connectionNames.contains(response.name) {
                    connection.name = "\(response.name) (\(ConnectionsCollector.connectionNames.count + 1))"
                } else {
                    connection.name = response.name
                }

                connection.providerId = response.providerId
                connection.publicKey = response.publicKey
                connection.apiVersion = response.apiVersion
                connection.supportEmail = response.supportEmail
                connection.logoUrlString = response.logoUrl?.absoluteString ?? ""
                connection.baseUrlString = response.baseUrl.absoluteString
                connection.geolocationRequired.value = response.geolocationRequired

                submitNewConnection(
                    for: connection,
                    connectQuery: connectQuery,
                    success: success,
                    redirect: redirect,
                    failure: failure
                )
            },
            failure: failure
        )
    }

    /*
      Request to get SCA Service connection.
      Result is returned through callback.
    */
    static func getProviderConfiguration(
        from url: URL,
        success: @escaping (SEProviderResponseV2) -> (),
        failure: @escaping (String) -> ()
    ) {
        SEProviderManagerV2.fetchProviderData(
            url: url,
            onSuccess: success,
            onFailure: failure
        )
    }

    static func submitNewConnection(
        for connection: Connection,
        connectQuery: String?,
        success: @escaping (Connection, AccessToken) -> (),
        redirect: @escaping (Connection, String) -> (),
        failure: @escaping (String) -> ()
    ) {
        // 1. Create Provider's public key (SecKey)
        SECryptoHelper.createKey(
            from: connection.publicKey,
            isPublic: true,
            tag: "\(connection.guid)_provider_public_key"
        )

        // 2. Generate new RSA key pair for a new Connection by tag
        SECryptoHelper.createKeyPair(with: SETagHelper.create(for: connection.guid))

        // 3. Convert Connection's public key to pem
        guard let connectionPublicKeyPem = SECryptoHelper.publicKeyToPem(tag: SETagHelper.create(for: connection.guid)),
        // 4. Encrypt Connection's public key with Provider's public key (step 1)
              let encryptedData = try? SECryptoHelper.encrypt(
                connectionPublicKeyPem,
                tag: "\(connection.guid)_provider_public_key"
              ),
              let providerId = connection.providerId else { return }

        let params = SECreateConnectionParams(
            providerId: providerId,
            pushToken: UserDefaultsHelper.pushToken,
            connectQuery: connectQuery,
            encryptedRsaPublicKey: encryptedData
        )

        guard let connectUrl = connection.baseUrl else { return }

        // 5. Send request
        SEConnectionManager.createConnection(
            by: connectUrl,
            params: params,
            appLanguage: "en",
            onSuccess: { response in
                // TODO: Finish
                print(response)
            },
            onFailure: { error in
                print(error)
            }
        )
    }
}
