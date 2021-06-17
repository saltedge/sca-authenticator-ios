//
//  RequestParametersBuilderSpec
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
import SEAuthenticatorCore
@testable import SEAuthenticatorV2

class RequestParametersBuilderSpecV2: BaseSpec {
    override func spec() {
        describe("confirmAuthorizationParams(for:)") {
            it("should return parameters from providerData to obtain token") {
                let encryptedData = SEEncryptedData(data: "data", key: "key", iv: "iv")
                let expirationTime = Date().addingTimeInterval(5.0 * 60.0).utcSeconds
                
                let expectedParams: [String: Any] = [
                    ParametersKeys.data: [
                        ParametersKeys.data: encryptedData.data,
                        ParametersKeys.key: encryptedData.key,
                        ParametersKeys.iv: encryptedData.iv
                    ],
                    ParametersKeys.exp: expirationTime
                ]

                let result = RequestParametersBuilder.confirmAuthorizationParams(
                    encryptedData: encryptedData,
                    exp: expirationTime
                ) == expectedParams

                expect(result).to(beTruthy())
            }
        }

        describe("actionParameters") {
            it("should retun correct dict") {
                let data = SEActionRequestDataV2(
                    url: URL(string: "https://url.com")!,
                    connectionGuid: "123",
                    accessToken: "456",
                    appLanguage: "en",
                    providerId: "1",
                    actionId: "99",
                    connectionId: "15"
                )
                let expirationTime = Date().addingTimeInterval(5.0 * 60.0).utcSeconds

                let expectedParams: [String: Any] = [
                    SENetKeys.data: [
                        ParametersKeys.providerId: data.providerId,
                        ParametersKeys.actionId: data.actionId,
                        ParametersKeys.connectionId: data.connectionId
                    ],
                    ParametersKeys.exp: expirationTime
                ]

                let result = RequestParametersBuilder.actionParameters(requestData: data) == expectedParams

                expect(result).to(beTruthy())
            }
        }
    }
}

