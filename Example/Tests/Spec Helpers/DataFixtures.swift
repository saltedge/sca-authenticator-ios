//
//  DataFixtures.swift
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

class DataFixtures {
    static var privateKey: String { return pem("test_private") }
    static var publicKey: String { return pem("test_public") }

    static var validProviderResponse: [String: Any] { return json("valid_provider_response") }
    static var invalidProviderResponse: [String: Any] { return json("invalid_provider_response") }

    static var validEncryptedAuthorizationData: [String: Any] { return json("valid_encrypted_authorization_data") }
    static var validEncryptedAuthorizationsData: [String: Any] { return json("valid_encrypted_authorizations_data") }

    static var validConfirmAuthorizationData: [String: Any] { return json("valid_confirm_authorization_data") }
    static var invalidConfirmAuthorizationData: [String: Any] { return json("invalid_confirm_authorization_data") }

    static var validCreateConnectionData: [String: Any] { return json("valid_create_connection_data") }
    static var invalidCreateConnectionData: [String: Any] { return json("invalid_create_connection_data") }

    static var validRevokeConnectionData: [String: Any] { return json("valid_revoke_connection_data") }
    static var invalidRevokeConnectionData: [String: Any] { return json("invalid_revoke_connection_data") }

    static var correctEncryptedJson: [String: Any] { return json("correct_encrypted_data") }
    static var incorrectEncryptedJson: [String: Any] { return json("incorrect_encrypted_data") }

    private static func json(_ filename: String) -> [String: Any] {
        let path = Bundle(for: self).path(forResource: filename, ofType: "json")!
        let jsonString = try! String(contentsOfFile: path, encoding: String.Encoding.utf8)
        return jsonString.json!
    }

    private static func pem(_ filename: String) -> String {
        let path = Bundle(for: self).path(forResource: filename, ofType: "pem")!
        let pemString = try! String(contentsOfFile: path, encoding: String.Encoding.utf8)
        return pemString
    }
}
