//
//  RequestParametersBuilderSpec.swift
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

class RequestParametersBuilderSpec: BaseSpec {
    override func spec() {
        describe("ParametersKeys") {
            it("should return corresponding parameter keys") {
                expect(ParametersKeys.data).to(equal("data"))
                expect(ParametersKeys.providerCode).to(equal("provider_code"))
                expect(ParametersKeys.credentials).to(equal("credentials"))
                expect(ParametersKeys.publicKey).to(equal("public_key"))
                expect(ParametersKeys.deviceInfo).to(equal("device_info"))
                expect(ParametersKeys.platform).to(equal("platform"))
                expect(ParametersKeys.pushToken).to(equal("push_token"))
                expect(ParametersKeys.returnUrl).to(equal("return_url"))
                expect(ParametersKeys.confirm).to(equal("confirm"))
                expect(ParametersKeys.authorizationCode).to(equal("authorization_code"))
            }
        }

        describe("parameters(for:)") {
            it("should return parameters from providerData to obtain token") {
                let connectionGuid = "connection_guid"
                let connectionCode = "demobank"
                let connectionData = SEConnectionData(code: connectionCode, tag: connectionGuid)!

                let pushToken = "abcd1234"
                UserDefaultsHelper.pushToken = pushToken
                
                let expectedParams = [
                    ParametersKeys.data: [
                        ParametersKeys.providerCode: connectionData.providerCode,
                        ParametersKeys.publicKey: connectionData.publicKey,
                        ParametersKeys.returnUrl: "authenticator://oauth/redirect",
                        ParametersKeys.platform: "ios",
                        ParametersKeys.pushToken: pushToken,
                        ParametersKeys.connectQuery: nil
                    ]
                ]

                let isEqual = RequestParametersBuilder.parameters(for: connectionData,
                                                                  pushToken: pushToken,
                                                                  connectQuery: nil) == expectedParams

                expect(isEqual).to(beTruthy())
            }
        }
    }
}
