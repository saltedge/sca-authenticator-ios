//
//  SEConnectionRouterSpecV2
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

class SEConnectionRouterSpecV2: BaseSpec {
    override func spec() {
        let baseUrl = URL(string: "https://baseUrl.com")!
        let baseUrlPath = "/api/authenticator/v2/connections"
        
        describe("ConnectionRouter") {
            context(".createConnection") {
                it("should create a valid url request") {
                    let encryptedData = SEEncryptedData(data: "data", key: "key", iv: "iv")
                    let data = SECreateConnectionParams(
                        providerId: "12",
                        pushToken: "push_token",
                        connectQuery: "connect_query",
                        encryptedRsaPublicKey: encryptedData
                    )

                    let expectedRequest = URLRequestBuilder.buildUrlRequest(
                        with: baseUrl.appendingPathComponent(baseUrlPath),
                        method: HTTPMethod.post.rawValue,
                        headers: Headers.requestHeaders(with: "en"),
                        params: RequestParametersBuilder.parameters(for: data),
                        encoding: .json
                    )

                    let actualRequest = SEConnectionRouter.createConnection(baseUrl, data, "en").asURLRequest()

                    expect(actualRequest).to(equal(expectedRequest))
                }
            }

            context(".revoke") {
                it("should create a valid url request") {
                    let connectionGuid = "guid"
                    let entityId = "1"
                    let accessToken = "access_token"
                    let parameters: [String : Any] = [
                        ParametersKeys.data: [:],
                        ParametersKeys.exp: Date().addingTimeInterval(5.0 * 60.0).utcSeconds
                    ]

                    let headers = Headers.signedRequestHeaders(
                        token: accessToken,
                        payloadParams: parameters,
                        connectionGuid: connectionGuid
                    )

                    let expectedRequest = URLRequestBuilder.buildUrlRequest(
                        with: baseUrl.appendingPathComponent("/api/authenticator/v2/connections/\(entityId)/revoke"),
                        method: HTTPMethod.delete.rawValue,
                        headers: headers,
                        params: parameters
                    )

                    let actualRequest = SEConnectionRouter.revoke(
                        SEBaseAuthenticatedWithIdRequestData(
                            url: baseUrl,
                            connectionGuid: connectionGuid,
                            accessToken: accessToken,
                            appLanguage: "en",
                            entityId: entityId
                        )
                    ).asURLRequest()

                    expect(actualRequest).to(equal(expectedRequest))
                }
            }
        }
    }
}

