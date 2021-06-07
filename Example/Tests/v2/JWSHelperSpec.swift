//
//  JWSHelperSpec
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

import Quick
import Nimble
import JOSESwift
import SEAuthenticatorCore
@testable import SEAuthenticatorV2

class JWSHelperSpec: BaseSpec {
    override func spec() {
        let connection = SpecUtils.createConnection(id: "1")

        describe("sign") {
            it("should return detached jws signature") {
                let expectedMessageDict = ["data": "Test Message"]

                // create actual jws signature without payload
                let actualSignature = JWSHelper.sign(params: expectedMessageDict, guid: connection.guid)!
                let splittedActualSignature = actualSignature.split(separator: ".")

                // serialize expected payload
                let jsonData = ParametersSerializer.createBody(parameters: expectedMessageDict)!.base64EncodedString()

                // insert expected payload into actual jws signature
                let final = splittedActualSignature[0] + ".\(jsonData)." + splittedActualSignature[1]

                // verify data
                do {
                    let jws = try JWS(compactSerialization: String(final))
                    let verifier = Verifier(
                        verifyingAlgorithm: .RS256,
                        publicKey: try SECryptoHelper.publicKey(for: SETagHelper.create(for: connection.guid))
                    )!
                    let payload = try jws.validate(using: verifier).payload
                    let message = String(data: payload.data(), encoding: .utf8)!

                    expect(message.json! == expectedMessageDict).to(beTrue())
                }
            }
        }

        func jwsSign(payload: [String: String], guid: String) -> String {
            let payloadBody = ParametersSerializer.createBody(parameters: payload)!
            let privateKey = SpecUtils.privateKey(for: SETagHelper.create(for: guid))!
            let signer = Signer(signingAlgorithm: .RS256, key: privateKey)!

            let header = JWSHeader(algorithm: .RS256)

            return try! JWS(header: header, payload: Payload(payloadBody), signer: signer).compactSerializedString
        }
    }
}
