//
//  SpecUtils.swift
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
import SEAuthenticator

struct SpecUtils {
    static func createConnection(id: ID) -> Connection {
        let connection = Connection()
        connection.id = id
        connection.baseUrlString = "url.com"
        ConnectionRepository.save(connection)
        _ = SECryptoHelper.createKeyPair(with: SETagHelper.create(for: connection.guid))

        return connection
    }

    static func createAuthResponse(with authMessage: [String: Any], id: ID, guid: GUID) -> SEAuthorizationData {
        let encryptedData = try! SECryptoHelper.encrypt(authMessage.jsonString!, tag: SETagHelper.create(for: guid))

        let dict = [
            "data": encryptedData.data,
            "key": encryptedData.key,
            "iv": encryptedData.iv,
            "connection_id": id,
            "algorithm": "AES-256-CBC"
        ]

        return SEEncryptedData(dict)!.decryptedAuthorizationData!
    }
}
