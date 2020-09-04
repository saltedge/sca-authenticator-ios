//
//  SEEncryptedDataExtensionsSpec.swift
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

import Quick
import Nimble
@testable import SEAuthenticator

class SEEncryptedDataExtensionsSpec: BaseSpec {
    override func spec() {
        describe("decryptedAuthorizationData()") {
            context("when given response is connect") {
                it("should return decrypted data from given response") {
                    let connection = Connection()
                    connection.id = "12345"
                    _ = SECryptoHelper.createKeyPair(with: SETagHelper.create(for: connection.guid))
                    ConnectionRepository.save(connection)

                    let authMessage = ["id": "00000",
                                       "connection_id": connection.id,
                                       "title": "Authorization",
                                       "description": "Test authorization",
                                       "created_at": Date().iso8601string,
                                       "expires_at": Date().addingTimeInterval(5.0 * 60.0).iso8601string]
                    let encryptedData = try! SECryptoHelper.encrypt(authMessage.jsonString!, tag: SETagHelper.create(for: connection.guid))
                    let dict = [
                        "data": encryptedData.data,
                        "key": encryptedData.key,
                        "iv": encryptedData.iv,
                        "connection_id": connection.id,
                        "algorithm": "AES-256-CBC"
                    ]
                    let expectedData = SEAuthorizationData(authMessage)

                    expect(expectedData).to(equal(SEEncryptedData(dict)!.decryptedAuthorizationData!))
                }
            }

            context("when given authorization is missing data") {
                it("should return nil") {
                    let connection = Connection()
                    _ = SECryptoHelper.createKeyPair(with: SETagHelper.create(for: connection.guid))

                    let authMessage = ["connection_id": nil,
                                       "title": "Authorization",
                                       "description": "Test authorization",
                                       "created_at": Date().iso8601string,
                                       "expires_at": Date().addingTimeInterval(5.0 * 60.0).iso8601string,
                                       "authorization_code": "some code"]
                    let encryptedData = try! SECryptoHelper.encrypt(authMessage.jsonString!, tag: SETagHelper.create(for: connection.guid))
                    let dict = [
                        "data": encryptedData.data,
                        "key": encryptedData.key,
                        "iv": encryptedData.iv,
                        "connection_id": connection.id,
                        "algorithm": "AES-256-CBC"
                    ]

                    expect(SEEncryptedData(dict)!.decryptedAuthorizationData).to(beNil())
                }
            }
        }
    }
}
