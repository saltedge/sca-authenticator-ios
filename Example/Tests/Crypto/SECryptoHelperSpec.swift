//
//  SECryptoHelperSpec
//  This file is part of the Salt Edge Authenticator distribution
//  (https://github.com/saltedge/sca-authenticator-ios)
//  Copyright © 2022 Salt Edge Inc.
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
@testable import SEAuthenticatorCore

class SECryptoHelperSpec: BaseSpec {
    override func spec() {
        let connection: Connection = {
            let c = Connection()
            c.id = "1234"
            SECryptoHelper.createKeyPair(with: SETagHelper.create(for: c.guid))
            return c
        }()
        let tag = SETagHelper.create(for: connection.guid)

        describe("decrypt(key:, tag:)") {
            it("should decrypt message") {
                let accessTokenMessage = "{\"access_token\": \"123456\"}"
                let encryptedToken = try! SpecCryptoHelper.publicEncrypt(data: accessTokenMessage.data(using: .utf8)!, keyForTag: tag)

                let expectedDecryptedToken = try! SECryptoHelper.decrypt(key: encryptedToken.base64EncodedString(), tag: tag)

                expect(expectedDecryptedToken.json!["access_token"] as? String).to(equal("123456"))
            }
        }

        describe("generateRandomBytes") {
            it("should correctly genrate non empty array of bytes") {
                let iv = try! SECryptoHelper.generateRandomBytes(count: 16)
                let isIvValid = [UInt8](iv).allSatisfy({ $0 != 0 })

                expect(isIvValid).to(beTrue())
            }
        }
    }
}
