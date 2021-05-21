//
//  SEAuthorizationRouterSpecV2
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

class SEAuthorizationRouterSpecV2: BaseSpec {
    override func spec() {
        let baseUrl = URL(string: "https://baseUrl.com")!
        let baseUrlPath = "/api/authenticator/v2/authorizations"
        let accessToken = "access_token"

        describe("AuthorizationsRouter") {
            context("when it's .list") {
                it("should create a valid url request") {
                    let expectedRequest = URLRequestBuilder.buildUrlRequest(
                        with: baseUrl.appendingPathComponent(baseUrlPath),
                        method: HTTPMethod.get.rawValue,
                        headers: Headers.authorizedRequestHeaders(token: accessToken),
                        encoding: .url
                    )

                    let request = SEAuthorizationRouter.list(baseUrl, accessToken).asURLRequest()

                    expect(request).to(equal(expectedRequest))
                }
            }

            context("when it's .show") {
                it("should create a valid url request") {
                    let data = SEBaseAuthenticatedWithIdRequestData(
                        url: baseUrl,
                        connectionGuid: "123guid",
                        accessToken: accessToken,
                        appLanguage: "en",
                        entityId: "1"
                    )

                    let expectedRequest = URLRequestBuilder.buildUrlRequest(
                        with: baseUrl.appendingPathComponent("\(baseUrlPath)/\(data.entityId)"),
                        method: HTTPMethod.get.rawValue,
                        headers: Headers.authorizedRequestHeaders(token: accessToken),
                        encoding: .url
                    )

                    let request = SEAuthorizationRouter.show(data).asURLRequest()

                    expect(request).to(equal(expectedRequest))
                }
            }

            context("when it's .confirm") {
                it("should create a valid url request") {
                    let data = SEAuthorizationRequestData(
                        id: "1",
                        authorizationCode: "authorization_code",
                        userAuthorizationType: "passcode",
                        geolocation: "GEO:",
                        connectionGuid: "123guid"
                    )
                    let parameters = RequestParametersBuilder.confirmAuthorizationParams(
                        encryptedData: data.encryptedData,
                        exp: Date().addingTimeInterval(5.0 * 60.0).utcSeconds
                    )
                    let headers = Headers.signedRequestHeaders(
                        token: accessToken,
                        payloadParams: parameters,
                        connectionGuid: "123guid"
                    )

                    let expectedRequest = URLRequestBuilder.buildUrlRequest(
                        with: baseUrl.appendingPathComponent("\(baseUrlPath)/\(data.id)/confirm"),
                        method: HTTPMethod.put.rawValue,
                        headers: headers,
                        params: parameters,
                        encoding: .json
                    )

                    let request = SEAuthorizationRouter.confirm(baseUrl, accessToken, data).asURLRequest()

                    expect(request).to(equal(expectedRequest))
                }
            }

            context("when it's .deny") {
                it("should create a valid url request") {
                    let data = SEAuthorizationRequestData(
                        id: "1",
                        authorizationCode: "authorization_code",
                        userAuthorizationType: "passcode",
                        geolocation: "GEO:",
                        connectionGuid: "123guid"
                    )
                    let parameters = RequestParametersBuilder.confirmAuthorizationParams(
                        encryptedData: data.encryptedData,
                        exp: Date().addingTimeInterval(5.0 * 60.0).utcSeconds
                    )
                    let headers = Headers.signedRequestHeaders(
                        token: accessToken,
                        payloadParams: parameters,
                        connectionGuid: "123guid"
                    )

                    let expectedRequest = URLRequestBuilder.buildUrlRequest(
                        with: baseUrl.appendingPathComponent("\(baseUrlPath)/\(data.id)/deny"),
                        method: HTTPMethod.put.rawValue,
                        headers: headers,
                        params: parameters,
                        encoding: .json
                    )

                    let request = SEAuthorizationRouter.deny(baseUrl, accessToken, data).asURLRequest()

                    expect(request).to(equal(expectedRequest))
                }
            }
        }
    }
}
